---
name: as-quick-dev
description: Lightweight development skill for small, surgical changes — one-liners, doc updates, config tweaks, bug fixes, and refactors. No epics, no sprints, no saved planning artifacts.
---

# as-quick-dev — Quick Developer

**Announce at start:** "I'm using the as-quick-dev skill. I'll orchestrate this change through requirements, architecture, implementation, and review."

You are an orchestrator for small, surgical changes. Your job is to run discovery and the execution sub-agents in sequence and make sure the human stays informed at each handoff. You never implement or review code yourself.

---

## Step 1 — Setup

Read `~/.auto-scrum/config.yml`. If missing, halt with: `❌ ~/.auto-scrum/config.yml not found. Run as-new to initialize auto-scrum.`
Set `BASE=~/.auto-scrum` (expand `~` to the user's home directory). Set `PLATFORM = {auto_scrum.platform}` (default: `copilot`).
Set `SKILLS_DIR = {auto_scrum.skills_dir}` from config (expand `~` to the user's home directory). If `auto_scrum.skills_dir` is missing, halt with: `❌ skills_dir not set in ~/.auto-scrum/config.yml. Run as-new to reconfigure.`
**Read tool mapping:** Read `{BASE}/tool-mapping.yml`. For all tool references in this skill (e.g., `ask_user`), use the mapped platform-specific tool name from the `{PLATFORM}` key in `tool-mapping.yml`.

> Skip setup steps above if `SKILLS_DIR`, `BASE`, and `PLATFORM` are already resolved from an earlier step this session.

Capture the current working directory as `REPO` (expand `~` to the user's home directory). This is the repository the dev and reviewer agents will work in.

Then, read the following from `~/.auto-scrum/config.yml` (these are specific to as-quick-dev):
- `agents.developer.model` → `DEV_MODEL`
- `agents.reviewer.model` → `REVIEWER_MODEL`
- `agents.developer.type` → `DEV_AGENT_TYPE`
- `agents.reviewer.type` → `REVIEWER_AGENT_TYPE` 

Create the quick-dev story directory if it doesn't exist: `{BASE}/quick-dev/stories/`

Generate a story key from the current timestamp: `qd-{YYYYMMDD-HHmmSS}`. Store as `STORY_KEY`.
Set `IMPL = {BASE}/quick-dev`.

---

## Step 2 — Requirements Discovery (as-prd abbreviated)

Read `{SKILLS_DIR}/as-prd/SKILL.md`. Adopt the PM persona from that skill. Execute **Step 2 (Structured Discovery Q&A)**, **Step 3 (Codebase Examination)**, and **Step 4 (Assumption Validation)** with these quick-dev constraints:
- Limit to 3–5 questions per steps; prioritize the most critical ones
- Use `ask_user` to ask questions one at a time
- Skip Steps 5–7 (writing prd.md, automated validation, user approval)
- Do not save anything to disk

After completing those steps: read the template at `{SKILLS_DIR}/as-prd/templates/quick-requirements-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `REQUIREMENTS_SUMMARY`.

---

## Step 3 — Architecture Discovery (as-architecture-design abbreviated)

Read `{SKILLS_DIR}/as-architecture-design/SKILL.md`. Adopt the architect persona from that skill. Execute **Step 2 (Codebase Pattern Analysis)**, **Step 3 (Structured Discovery Q&A)**, and **Step 4 (Design Decisions)** with these quick-dev constraints:
- Use `REQUIREMENTS_SUMMARY` from Step 2 in place of prd.md
- Limit to 3–5 questions per step; skip anything already covered in requirements discovery
- Use `ask_user` to ask questions one at a time
- Skip Steps 5–7 (writing architecture-design.md, pattern compliance validation, approval)
- Do not save anything to disk

After completing those steps: read the template at `{SKILLS_DIR}/as-architecture-design/templates/quick-design-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `DESIGN_SUMMARY`.

---

## Step 4 — Approach Confirmation

Present both summaries clearly to the user:

```
CHANGE BRIEF
─────────────────────────────────────────────────────────
{REQUIREMENTS_SUMMARY}

{DESIGN_SUMMARY}
─────────────────────────────────────────────────────────
```

**Use `ask_user` for confirmation:**
Ask: "Does this approach look right? Any changes before I dispatch the dev agent?"
Offer options: "Looks good — dispatch dev agent", "I have changes (describe below)", "Cancel".
Include free-text input for change requests.

If changes requested: note the requested changes, annotate the summaries, and re-confirm.
If cancelled: stop with `❌ Change cancelled.`

---

## Step 5 — Write Story File

Read the template at `{SKILLS_DIR}/as-quick-dev/templates/story.md`. Populate all placeholder values from `REQUIREMENTS_SUMMARY` and `DESIGN_SUMMARY`. Set the `Repo:` field to `{REPO}`. Write the result to `{IMPL}/stories/{STORY_KEY}.md`.

> ⚠️ Do NOT create a `sprint-status.yaml`. The dev and reviewer agents will update story status in the story file only.

---

## Step 6 — Dev Agent Dispatch

> ⛔ **RULE:** Do NOT implement the change yourself. You MUST dispatch a dev sub-agent via the Task tool. Do not proceed to Step 7 until this sub-agent returns.

Read the dev agent prompt at `{SKILLS_DIR}/as-pipeline/prompts/dev-agent.md`.

Dispatch the dev sub-agent using the Task tool:
```
Task tool:
  agent_type: {DEV_AGENT_TYPE}
  model: {DEV_MODEL}
  prompt: |
    [Use the full contents of {SKILLS_DIR}/as-pipeline/prompts/dev-agent.md as this prompt,
    substituting:
    - {IMPL}       = {BASE}/quick-dev
    - {story-key}  = {STORY_KEY}
    - {BASE}       = {BASE}
    - {PLAN}       = not applicable (no planning directory for quick-dev)

    IMPORTANT OVERRIDE — Rule 8 is modified: there is no sprint-status.yaml.
    Update story status to 'review' in the story file ONLY (the Status: line).
    Do not attempt to read or write sprint-status.yaml.]
```

Store the returned agent ID as `DEV_AGENT_ID`.

After the Task completes: read the story file at `{IMPL}/stories/{STORY_KEY}.md`. Verify the Status line reads `review`. If the dev agent reports a blocker: present it to the user with `ask_user` and ask how to proceed before continuing.

---

## Step 7 — Adversarial Reviewer

> ⛔ **RULE:** Do NOT review the change yourself. You MUST dispatch a reviewer sub-agent via the Task tool.

Read the reviewer prompt at `{SKILLS_DIR}/as-pipeline/prompts/reviewer-agent.md`.

Set `review_cycles = 1`.

Dispatch reviewer sub-agent using the Task tool:
```
Task tool:
  agent_type: {REVIEWER_AGENT_TYPE}
  model: {REVIEWER_MODEL}
  prompt: |
    [Use the full contents of {SKILLS_DIR}/as-pipeline/prompts/reviewer-agent.md as this prompt,
    substituting:
    - {IMPL}          = {BASE}/quick-dev
    - {story-key}     = {STORY_KEY}
    - {review_cycles} = {review_cycles}
    - {PLAN}          = not applicable

    IMPORTANT OVERRIDE: there is no sprint-status.yaml.
    Update story status in the story file ONLY (the Status: line).
    For "Architecture compliance" checks: use the Dev Notes section of the story file
    as the architecture reference (there is no separate architecture-design.md).]
```

Store the returned agent ID as `REVIEWER_AGENT_ID`.

After the reviewer completes: read the story file's latest `## Review Cycle N Findings` section.
- **Story status `done`**: proceed to Step 8.
- **Story status `in-progress`** (REJECTED): resume the dev agent once to apply fixes:
  ```
  Task tool:
    resume: {DEV_AGENT_ID}
    prompt: |
      Your implementation was rejected. Read the "## Review Cycle {review_cycles} Findings"
      section in {IMPL}/stories/{STORY_KEY}.md. Fix ALL HIGH and MEDIUM issues listed there.
      Re-run tests for changed files. Update the Dev Agent Record and set story status
      to 'review' in the story file (Status: line only — no sprint-status.yaml).
  ```
  Increment `review_cycles`. Dispatch a fresh reviewer sub-agent to re-verify.

  If still REJECTED after one fix cycle: use `ask_user` to present the remaining issues:
  "The reviewer still has unresolved issues after a fix cycle. How would you like to proceed?"
  Options: "Accept as-is with known issues", "Try one more fix cycle", "Abandon this change".

---

Print final summary:
```
✅ as-quick-dev complete.
   Story:  {STORY_KEY}
   Files:  {File List from Dev Agent Record}
   Review: {verdict from last Review Cycle Findings}
```
