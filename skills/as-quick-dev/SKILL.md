---
name: as-quick-dev
description: Lightweight development skill for small, surgical changes — one-liners, doc updates, config tweaks, bug fixes, and refactors. No epics, no sprints, no saved planning artifacts.
---

# as-quick-dev — Quick Developer

**Announce at start:** "I'm using the as-quick-dev skill. I'll orchestrate this change through requirements, architecture, implementation, and review."

You are an orchestrator for small, surgical changes. Your job is to run discovery and the execution sub-agents in sequence and make sure the human stays informed at each handoff. You never implement or review code yourself.

---

## Step 1 — Setup

**Check for scaffolding:**
If `~/.auto-scrum/config.yml` does **not** exist:
1. Probe candidate skill directories in this order (expand `~` in all paths):
   - `~/.config/opencode/skills`
   - `~/.copilot/skills`
   - `~/.claude/skills`
   - `.github/copilot/skills`
   - `.claude/skills`
   Set `SKILLS_DIR` to the first directory that contains `as-setup/setup.sh`.
   If no candidate contains that script, halt with:
   `❌ Could not find as-setup/setup.sh. Checked: ~/.config/opencode/skills, ~/.copilot/skills, ~/.claude/skills, .github/copilot/skills, .claude/skills`
2. Use `ask_user` to prompt:
   "auto-scrum isn't initialized yet (`~/.auto-scrum/config.yml` not found). Run setup now?"
   Options: "Run setup", "Cancel"
3. If "Cancel": halt with `❌ Setup skipped. Run as-new or bash {SKILLS_DIR}/as-setup/setup.sh to initialize auto-scrum.`
4. If "Run setup": run `bash {SKILLS_DIR}/as-setup/setup.sh`
   If the script exits with a non-zero status, halt and display the script's error output.

Read `~/.auto-scrum/config.yml`.
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

**Capture the task description.** The user provides a change to make (e.g. "fix the off-by-one in the pagination helper", "add a `--dry-run` flag to the import command", "refactor the retry logic to use the shared backoff util"). If no task description was given in the invocation or prompt, use `ask_user` to ask: "What change do you need? Describe the task." Store as `TASK`.

### Complexity Gate — is this a quick-dev or a full pipeline job?

Before any other work, judge whether `TASK` belongs in this lightweight flow or the full planning pipeline. Use holistic judgment, **not** mechanical keyword matching.

**Escalation signals (too complex for quick-dev):**
- Multiple subsystems / modules changing together
- A new system, service, or subsystem built from scratch
- Changes to core data models, schemas, or public APIs that other components depend on
- Scope spanning many files across unrelated areas of the codebase (roughly >5 files, or unrelated directories)
- Architectural uncertainty — the request is really "how should we design/architect this?"
- A new cross-cutting concern introduced (new auth model, new persistence layer, new framework)

**Simplicity signals (good fit for quick-dev):**
- Single module / component focus
- Bug fix, config change, copy/doc update, small refactor, or localized enhancement
- Adding behavior to an existing, well-defined component
- Confident, specific request with clear scope
- ~1–5 files affected

**If 2+ escalation signals are present**, use `ask_user`:
"This looks like it may be too big for a quick change — I'd recommend the full planning pipeline."
Offer options: "Use full pipeline", "Proceed with quick-dev anyway".
If the user chooses the full pipeline: print `Start with /as-new <feature-name>, then /as-prd to begin the full planning pipeline.` and stop.

Otherwise, proceed to Step 2.

---

## Step 2 — Context Gathering (delegated)

**Delegate the codebase scan to a single read-only explore subagent** — dispatch it using the `dispatch_subagent` mechanism with the `explore_agent` type from `tool-mapping.yml`, running on `{DEV_MODEL}` (if those keys are absent from your `tool-mapping.yml`, dispatch your platform's standard read-only exploration subagent). This keeps the heavy file reads out of your context: the subagent reads broadly in its own throwaway context and returns only a findings digest. This single scan replaces the per-step codebase scans the borrowed as-prd / as-architecture steps would otherwise each run — **do not let Steps 3 and 4 scan again.**

Give it `TASK` for orientation and instruct it to be **very thorough** — keep expanding until it understands all code related to this change, not just the obvious matches — and to return a concise structured digest (findings plus concrete `file:line` references, **not raw file dumps**) covering:

1. **Files to modify / create** — the specific files this change touches, each with path and purpose.
2. **Relevant patterns & conventions** — code style, existing patterns for similar functionality, import/export conventions, error-handling approach, and the nearby **test patterns / framework / harness** to follow.
3. **Dependencies & impact** — internal module dependencies, external libraries, config files that may need updates, related files that might be affected, and any state/data this change reads or writes.
4. **Constraints & gotchas** — anti-patterns to avoid and stack-specific pitfalls relevant to this change.
5. **Edge cases** — cases implied by the code that the task description did not call out.
6. **Existing tests** — test files covering this area, what they assert, and whether they will need updating.

Read the digest and carry only its conclusions forward. Store it as `CONTEXT_DIGEST`.

---

## Step 3 — Requirements Discovery (as-prd abbreviated)

Read `{SKILLS_DIR}/as-prd/SKILL.md`. Adopt the PM persona from that skill. Execute **Step 2 (Structured Discovery Q&A)** and **Step 4 (Assumption Validation)** with these quick-dev constraints:
- The codebase examination (that skill's Step 3) was already delegated in Step 2 above — do **not** repeat it. Use `CONTEXT_DIGEST` in its place.
- Limit to 3–5 questions; prioritize the most critical ones
- Use `ask_user` to ask questions one at a time
- Skip Steps 5–7 (writing prd.md, automated validation, user approval)
- Do not save anything to disk

After completing those steps: read the template at `{SKILLS_DIR}/as-prd/templates/quick-requirements-summary.md` and produce a completed version with all placeholder values replaced by real content. Number the acceptance criteria AC-1, AC-2, etc. Store as `REQUIREMENTS_SUMMARY`.

---

## Step 4 — Architecture Discovery (as-architecture-design abbreviated)

Read `{SKILLS_DIR}/as-architecture-design/SKILL.md`. Adopt the architect persona from that skill. Execute **Step 3 (Structured Discovery Q&A)** and **Step 4 (Design Decisions)** with these quick-dev constraints:
- The codebase pattern analysis (that skill's Step 2) was already delegated in Step 2 above — do **not** repeat it. Use `CONTEXT_DIGEST` (files, patterns, dependencies, gotchas) and `REQUIREMENTS_SUMMARY` in place of prd.md and that skill's Step 2 scan output.
- Limit to 3–5 questions; skip anything already covered in requirements discovery
- Use `ask_user` to ask questions one at a time
- Skip Steps 5–7 (writing architecture-design.md, pattern compliance validation, approval)
- Do not save anything to disk

After completing those steps: read the template at `{SKILLS_DIR}/as-architecture-design/templates/quick-design-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `DESIGN_SUMMARY`.

---

## Step 5 — Test Planning (as-test-plan abbreviated)

Read `{SKILLS_DIR}/as-test-plan/SKILL.md`. Adopt the QA Engineer persona from that skill. Execute an abbreviated version of **Step 3 (Extract & Prioritize Acceptance Criteria)** and **Step 4 (Design Test Scenarios)** with these quick-dev constraints:
- Use the numbered ACs from `REQUIREMENTS_SUMMARY`, plus `DESIGN_SUMMARY` and `CONTEXT_DIGEST` (existing tests, framework, conventions) as input
- Assign each AC a testability level:
  - `AUTO` — code behavior/logic/contract/state that can be asserted in an automated test
  - `AGENT-REVIEW` — doc, config, or structural change verified by inspection
  - `NONE` — dead-code/unused-import/comment-only removal confirmed by build/lint
- Design a concrete GIVEN-WHEN-THEN scenario for each `AUTO` AC (every `AUTO` AC needs ≥1 scenario). Skip scenario design for `AGENT-REVIEW` and `NONE` ACs.
- Skip AC priority assignment (P0–P3), writing test-plan.md, coverage/regression verification, and approval — those belong to the full pipeline
- Do not save anything to disk

After completing those steps: read the template at `{SKILLS_DIR}/as-quick-dev/templates/quick-test-summary.md` and produce a completed version with all placeholder values replaced by real content. Store as `TEST_SUMMARY`.

---

## Step 6 — Approach Confirmation

Present the summaries clearly to the user:

```
CHANGE BRIEF
─────────────────────────────────────────────────────────
{REQUIREMENTS_SUMMARY}

{DESIGN_SUMMARY}

{TEST_SUMMARY}
─────────────────────────────────────────────────────────
```

**Use `ask_user` for confirmation:**
Ask: "Does this approach look right? Any changes before I dispatch the dev agent?"
Offer options: "Looks good — dispatch dev agent", "I have changes (describe below)", "Cancel".
Include free-text input for change requests.

If changes requested: note the requested changes, annotate the summaries, and re-confirm.
If cancelled: stop with `❌ Change cancelled.`

---

## Step 7 — Write Story File

Read the template at `{SKILLS_DIR}/as-quick-dev/templates/story.md`. Populate all placeholder values from `REQUIREMENTS_SUMMARY`, `DESIGN_SUMMARY`, and `TEST_SUMMARY` (the AC testability and GIVEN-WHEN-THEN scenarios drive the Tasks/Subtasks and the Test Scenarios block). Set the `Repo:` field to `{REPO}`. Write the result to `{IMPL}/stories/{STORY_KEY}.md`.

> ⚠️ Do NOT create a `sprint-status.yaml`. The dev and reviewer agents will update story status in the story file only.

---

## Step 8 — Dev Agent Dispatch

> ⛔ **RULE:** Do NOT implement the change yourself. You MUST dispatch a dev sub-agent via the Task tool. Do not proceed to Step 9 until this sub-agent returns.

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

## Step 9 — Adversarial Reviewer

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
- **Story status `done`**: proceed to the final summary.
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
