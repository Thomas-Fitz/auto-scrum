---
name: as-quick-dev
description: Lightweight development skill for small, surgical changes — one-liners, doc updates, config tweaks, bug fixes, and refactors. No epics, no sprints, no saved planning artifacts.
---

# as-quick-dev — Quick Developer

**Announce at start:** "I'm using the as-quick-dev skill. I'll orchestrate this change through requirements, architecture, implementation, and review."

You are an orchestrator for small, surgical changes. Your job is to run the right discovery and execution sub-agents in sequence and make sure the human stays informed at each handoff. You never implement or review code yourself.

---

## Step 1 — Setup

Read `.auto-scrum/config.yml`. Set `SKILLS_DIR = {auto_scrum.skills_dir}` (expand `~` to the user's home directory). If `auto_scrum.skills_dir` is missing, halt with: `❌ skills_dir not set in .auto-scrum/config.yml. Run as-new to reconfigure.`
Set `BASE = {artifacts.base_dir}` (default: `.auto-scrum`). Set `PLATFORM = {auto_scrum.platform}` (default: `copilot`).
**Read tool mapping:** Read `{BASE}/tool-mapping.yml`. For all tool references in this skill (e.g., `ask_user`), use the mapped platform-specific tool name from the `{PLATFORM}` key in `tool-mapping.yml`.

> Skip setup steps above if `SKILLS_DIR`, `BASE`, and `PLATFORM` are already resolved from an earlier step this session.

Then, read the following from `.auto-scrum/config.yml` (these are specific to as-quick-dev):
- `agents.developer.model` → `DEV_MODEL`
- `agents.reviewer.model` → `REVIEWER_MODEL`
- `agents.developer.type` → `DEV_AGENT_TYPE`
- `agents.reviewer.type` → `REVIEWER_AGENT_TYPE` 

Read `{BASE}/cross-feature/project-context.md` if it exists. Store its contents as `PROJECT_CONTEXT`. If not found, set `PROJECT_CONTEXT = "Not available"`.

Create the quick-dev story directory if it doesn't exist: `{BASE}/quick-dev/stories/`

Generate a story key from the current timestamp: `qd-{YYYYMMDD-HHmmSS}`. Store as `STORY_KEY`.
Set `IMPL = {BASE}/quick-dev`.

---

## Step 2 — Requirements Discovery (as-prd Quick Mode)

Read `{SKILLS_DIR}/as-prd/SKILL.md`. Find the `## Quick Mode — Invoked by as-quick-dev` section and execute those instructions directly. Execute the Quick Mode steps yourself using `ask_user` to gather requirements from the user.

After completing the Quick Mode steps: read the template at `{SKILLS_DIR}/as-prd/templates/quick-requirements-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `REQUIREMENTS_SUMMARY`.

---

## Step 3 — Architecture Discovery (as-architecture-design Quick Mode)

Read `{SKILLS_DIR}/as-architecture-design/SKILL.md`. Find the `## Quick Mode — Invoked by as-quick-dev` section and execute those instructions directly. Execute the Quick Mode steps yourself, using `REQUIREMENTS_SUMMARY` from Step 2 in place of `prd.md` and using `ask_user` for architecture Q&A.

After completing the Quick Mode steps: read the template at `{SKILLS_DIR}/as-architecture-design/templates/quick-design-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `DESIGN_SUMMARY`.

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

Write a story file at `{IMPL}/stories/{STORY_KEY}.md` using the pipeline's story structure. Populate all fields from `REQUIREMENTS_SUMMARY` and `DESIGN_SUMMARY`:

```markdown
# Quick-Dev Story: {STORY_KEY}

Status: ready-for-dev

## Story
As a developer,
I want to {change description from REQUIREMENTS_SUMMARY},
so that {why from REQUIREMENTS_SUMMARY}.

## Acceptance Criteria
{List each AC from REQUIREMENTS_SUMMARY, numbered to match AC-1, AC-2, etc.}

## Tasks / Subtasks
{For each file in "Files to modify" / "Files to create" from DESIGN_SUMMARY, create a task.
 Assign testability based on DESIGN_SUMMARY testing approach:
 - Code changes with unit/integration tests → AUTO (use TDD subtasks: failing test, implement, refactor)
 - Doc/config/copy changes → AGENT-REVIEW (implement and verify build)
 - Removal of dead code or unused imports → NONE (remove and verify build/lint)}

## Dev Notes
**Architecture:** {Implementation approach from DESIGN_SUMMARY}
**Anti-patterns to avoid:** {Pattern deviations from DESIGN_SUMMARY, framed as what to avoid — or "None"}
**Files to modify:** {from DESIGN_SUMMARY}
**Files to create:** {from DESIGN_SUMMARY, or "None"}
**Test cases to satisfy:** {Testing approach from DESIGN_SUMMARY — include type and what to assert}
**Testing approach:** {from DESIGN_SUMMARY}
**Edge cases:** {from DESIGN_SUMMARY}
**Integration points:** {Integration risks from DESIGN_SUMMARY}

### Previous Learnings
N/A — as-quick-dev session

### References
- Derived from as-quick-dev session: Requirements Summary and Design Summary above

## Dev Agent Record
### Agent Model Used
### Completion Notes
### File List
### Plan Deviations
```

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

## Step 8 — Git Commit

**Use `ask_user` to ask about committing:**
Ask: "The change is done. Would you like to commit it?"
Offer options: "Yes — commit now", "No — I'll commit manually".

If "Yes — commit now":
1. Run `git add -A -- ':!{BASE}/quick-dev'` to stage implementation changes, excluding the quick-dev story artifact.
2. Run `git diff --cached --quiet`. If nothing is staged: print `Nothing to commit.` and stop.
3. Read the "Completion Notes" from the Dev Agent Record section of `{IMPL}/stories/{STORY_KEY}.md`.
4. Compose a concise commit message (≤72 chars) based on the Completion Notes. Plain language. No prefixes, no ticket keys, no boilerplate. Do NOT add any `Co-authored-by` or other trailer lines — the commit author must be exclusively the human git user.
5. Run `git commit -m "{message}"`.
6. Print: `✅ Committed: {message}`

Print final summary:
```
✅ as-quick-dev complete.
   Story:  {STORY_KEY}
   Files:  {File List from Dev Agent Record}
   Review: {verdict from last Review Cycle Findings}
```
