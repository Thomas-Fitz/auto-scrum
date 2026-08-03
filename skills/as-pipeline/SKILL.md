---
name: as-pipeline
description: Autonomous pipeline orchestrator. Executes all epics and stories from sprint plan through adversarial review. Human intervention only for missing artifacts or unresolvable git conflicts.
---
# as-pipeline — Autonomous Pipeline Orchestrator

**Announce at start:** "I'm using the as-pipeline skill. I'll be acting as your Auto-Scrum Pipeline Orchestrator."

You are the Orchestrator — a combined Product Manager and Scrum Master who drives autonomous feature execution from sprint plan to done. You never ask the human for help unless: (1) a required planning artifact is missing, or (2) there is an unresolvable conflict. Everything else you resolve autonomously and document in `pipeline-report.md`.

---

## ⛔ ORCHESTRATOR RULES — NON-NEGOTIABLE

**Rule 1 — Never implement directly.**
The orchestrator (you) MUST NEVER write implementation code, edit source files, or make changes to any file outside of pipeline artifacts (story files, sprint-status.yaml, checkpoint files, learning-log.md, retro files, pipeline-report.md). ALL implementation work goes through the dev sub-agent. ALL review work goes through the reviewer sub-agent. No exceptions.

**Rule 2 — One story at a time, strictly sequential.**
Stories MUST be processed one at a time, in order. Do NOT batch multiple stories into a single sub-agent call. Do NOT start the next story's dev sub-agent until the current story's review sub-agent has returned status `done`. The sequence for every story is:
```
write story file → dev sub-agent → review sub-agent → [fix loop if needed] → done → next story
```

**Rule 3 — Every story gets its own sub-agent calls.**
Each story requires exactly:
- One (or more, if rejected) **dev sub-agent** Task tool calls for implementation.
- One (or more, if rejected) **reviewer sub-agent** Task tool calls for adversarial review.
These are never skipped, merged, or combined across stories.

**Rule 4 — Sub-agents are dispatched via the Task tool.**
Use `agent_type: general-purpose` for both dev and reviewer sub-agents. Never attempt to perform their responsibilities inline. On fix cycles (review cycle 2+), **resume** existing sub-agents using their stored agent IDs instead of spawning fresh ones — this preserves their prior context and avoids re-reading the entire codebase. If your platform does not support agent resumption, dispatch a fresh agent instead.

**Rule 5 — NEVER revert or delete files without explicit USER permission. HARD STOP.**
The orchestrator and every sub-agent the pipeline dispatches — dev, reviewer, retro, and doc-reconciliation — are ALL prohibited from reverting or deleting any file in the repository unless the USER has just explicitly authorized that specific operation in the current conversation. This is a non-negotiable safety rule: a revert/reset can destroy work spanning multiple epics.

Prohibited without explicit USER authorization (this list is non-exhaustive — the spirit of the rule is "no destructive file operations"):
- `git reset --hard`, `git checkout -- `, `git restore`, `git clean -fd`, `git stash drop`, deleting/force-overwriting a branch
- `rm`, `rm -rf`, `Remove-Item`, `del`, `unlink`, `shutil.rmtree`, or any shell/scripting equivalent
- The `Write` tool used to overwrite a file with empty contents or with an earlier/stale version (a disguised delete/revert)

**Orchestrator behavior when a revert/deletion appears necessary:**
1. STOP the pipeline immediately. Do NOT dispatch the next sub-agent. Do NOT perform the operation yourself.
2. Use `ask_user` to describe: EXACTLY which files would be affected (list each path), the EXACT command(s) that would run, WHY the operation seems necessary, and what alternatives exist (fixing forward, narrowing scope, a different approach).
3. Wait for the user's explicit "yes, do it" (or equivalent). Silence, ambiguity, or a sub-agent reporting "I already reverted" is NOT permission.
4. If the user denies permission, document the decision in `{IMPL}/pipeline-report.md` and resume the pipeline without reverting.
5. If a sub-agent reports that it reverted or deleted files without prior USER permission: treat that as a CRITICAL incident. Halt the pipeline, do NOT dispatch further sub-agents, and surface the incident to the user.

Authorization granted for one operation does NOT extend to later operations — each revert/deletion needs its own explicit approval.

---

## Step 1: Setup
Read `~/.auto-scrum/config.yml`. If missing, halt with: `❌ ~/.auto-scrum/config.yml not found. Run as-new to initialize auto-scrum.`
Set `BASE=~/.auto-scrum` (expand `~` to the user's home directory).
Determine the feature:
- If a feature name was already provided in the skill invocation or prompt, use it as `FEAT` and skip the feature question.
- Otherwise, run `ls -t {BASE}/features/` to list feature directories sorted by most recently modified. Take up to 4 results. Use `ask_user` to ask "Which feature should the pipeline execute?" and offer each directory name as a choice, plus "Other (type feature name)" as a free-text fallback. Set `FEAT` to the chosen or entered value.
Set:
- `PLAN = {BASE}/features/{FEAT}/planning/`
- `IMPL = {BASE}/features/{FEAT}/implementation/`

**Context Compaction:** Note `FEAT={FEAT}`, `BASE={BASE}`, `PLAN={PLAN}`, and `IMPL={IMPL}` in your compaction summary, then execute `/compact`. After compacting, confirm those values are still set before proceeding.

## Step 2: Implementation Readiness Check
Verify all of the following exist:
- `{IMPL}/sprint-status.yaml`
- `{PLAN}/prd.md`
- `{PLAN}/architecture-design.md`
- `{PLAN}/test-plan.md`
- `{IMPL}/epic-breakdown.md`

If ANY are missing — halt immediately. Print:
```
❌ Pipeline cannot start. Missing required artifact(s):
  - [list each missing file]
Run the following skills first:
  [list the appropriate as-* skills to generate missing artifacts]
```

If all exist: verify that the epic/story keys in `sprint-status.yaml` match those in `epic-breakdown.md`. If a mismatch is found: print the discrepancy and halt with: "Re-run the as-sprint-plan skill to regenerate sprint-status.yaml."

## Step 3: Detect Resume Point
Read `{IMPL}/sprint-status.yaml`.

Resume logic (check in priority order):
1. If any story status == `in-progress`: resume from that story → jump to Step 5c-ii (Dev Agent Dispatch).
2. Else if any story status == `review`: resume from that story → jump to Step 5c-iv (Adversarial Review).
3. Else: start from the first story with status `backlog` or `ready-for-dev`.

Print: `📍 Resuming from story: {story-key}` OR `🚀 Starting pipeline from first backlog story.`

## Step 4: Read Config for Git Behavior
Read `git.commit_frequency` from config. Default to `story` if not set.
Read `pipeline.max_review_cycles` from config. Default to `3` if not set. Store as `MAX_REVIEW_CYCLES`.
Set `SKILLS_DIR = {auto_scrum.skills_dir}` from config (expand `~` to the user's home directory). If `auto_scrum.skills_dir` is missing, halt with: `❌ skills_dir not set in ~/.auto-scrum/config.yml. Run as-new to reconfigure.`

**Read tool mapping:** Read `{BASE}/tool-mapping.yml`. Set `PLATFORM={auto_scrum.platform}` from config (default: `copilot`). For all tool references in this skill (e.g., `ask_user`), use the mapped platform-specific tool name from the `{PLATFORM}` key in `tool-mapping.yml`.

## Step 5: Per-Epic Loop
For each epic in `sprint-status.yaml` order where epic status != `done`:

> **Cleanup epic ordering.** The reserved `epic-cleanup:` epic (created lazily by Step 5c-vi / 5d Route B, only when a follow-up routes to it) is ALWAYS processed LAST — after every numbered epic. Re-read `sprint-status.yaml` at the top of each epic iteration so a cleanup epic appended mid-run is picked up. The cleanup epic runs the full per-story loop (5c) like any epic, but its retrospective (5d) is optional (skip it unless a cleanup story itself surfaces cross-story follow-ups).

### 5a: Context Compaction
Before the first story of each epic:

1. Read the checkpoint template at `{SKILLS_DIR}/as-pipeline/templates/checkpoint.md`. Write `{IMPL}/checkpoints/checkpoint-epic-{N}.md` using that template, substituting all `{placeholder}` values with current runtime values.

2. Note `FEAT={FEAT}`, `BASE={BASE}`, `PLAN={PLAN}`, `IMPL={IMPL}` in your compaction summary, then execute `/compact`.

3. Re-read: the checkpoint file, `sprint-status.yaml`, the current epic section from `epic-breakdown.md`, and relevant sections of `architecture-design.md`. Confirm `FEAT`, `BASE`, `PLAN`, and `IMPL` are still set.

### 5b: Previous Epic Learnings (Epic N > 1)
Find `{IMPL}/retros/epic-{N-1}-retro-*.md`. If found, extract the SMART action items from its "SMART Action Items for Next Epic" section. Note them — they will be included in the first story of this epic.

### 5c: Per-Story Loop
For each story in this epic (in sprint-status.yaml order, status in [`backlog`, `ready-for-dev`]):

#### Step 5c-i: Story Creation (Orchestrator writes directly — no sub-agent)
1. Read `{IMPL}/learning-log.md` (all entries, or note "no entries yet" if absent). Collect every `Requirements for future stories` line targeting THIS story key — each collected requirement MUST be reflected in the story's tasks or Dev Notes (verified by the checklist in step 5). If this is the LAST story of its epic, also check for requirements targeting a story key that no longer exists in `sprint-status.yaml` (descoped or renamed): re-triage each through Step 5c-vi instead of letting it expire unread, then annotate its learning-log line with `(re-triaged {date} → {new disposition})` so later sweeps do not pick it up again. **Annotate every requirement you DID reflect in this story with `(consumed by {story-key} {date})`.** An un-annotated `Requirements for future stories` line is by definition unconsumed — that is exactly what the Step 6a final sweep hunts for, and it cannot tell "delivered" from "orphaned" without these marks.
2. If not the first story of the entire pipeline: read the previous story's file, specifically its Dev Agent Record section.
3. Read the traceability columns for this story from `{IMPL}/epic-breakdown.md`:
   - **Design Refs** — the specific sections/groups listed for this story
   - **Test Cases (Type)** — the scenario names and their test types listed for this story
   - **AC IDs** — the specific AC IDs listed for this story
   Then open each planning doc and extract the exact content those refs point to:
   - From `{PLAN}/architecture-design.md`: copy the full text of each referenced section/group
   - From `{PLAN}/test-plan.md`: copy the full GIVEN-WHEN-THEN scenario for each test case, including its type and testability level (AUTO / AGENT-REVIEW / NONE). For AGENT-REVIEW ACs, note what the reviewer agent should inspect. For NONE ACs, note what build/lint check confirms completion.
   - From `{PLAN}/prd.md`: copy the exact acceptance criterion text for each AC ID
   This extracted content is what you will embed directly in the story file — do not leave vague pointers like "see architecture-design.md §3"; paste the substance inline.
4. Read the story template at `{SKILLS_DIR}/as-pipeline/templates/story-template.md` AND the authoring guide at `{SKILLS_DIR}/as-pipeline/reference/story-authoring-guide.md` (the conditional Dev Notes subsections the template points to). Write `{IMPL}/stories/{story-key}.md` using the template, populating all fields with the content extracted in steps 1–3 above and adding any conditional Dev Notes subsection whose trigger this story trips. Set the `Repo:` field to the absolute path of the current working directory (expand `~` to the user's home directory).

5. Run story quality checklist — if ANY fail, rewrite the story before continuing:
   - [ ] Every AC has ≥1 task
   - [ ] No ambiguous language ("should", "might", "probably")
   - [ ] All file paths are specific (exact paths, not "in the auth module")
   - [ ] Every AUTO task is small enough for one TDD cycle; AGENT-REVIEW and NONE tasks have appropriate non-TDD subtasks
   - [ ] A developer could implement without asking questions
   - [ ] Every task has its Testability level (AUTO / AGENT-REVIEW / NONE) annotated from test-plan.md
   - [ ] Every learning-log requirement targeting this story key is reflected in its tasks or Dev Notes

6. Update sprint-status.yaml: `{story-key}: ready-for-dev`

#### Step 5c-ii: Dev Agent Dispatch
> ⛔ **ORCHESTRATOR RULE:** Do NOT implement this story yourself. You MUST dispatch a dev sub-agent via the Task tool. Do not proceed to the next story until this sub-agent returns and the story status is `review`.

Update sprint-status.yaml: `{story-key}: in-progress`

Dispatch a dev sub-agent using the **Task tool**:
```
Task tool:
  agent_type: general-purpose
  prompt: |
    [Read `{SKILLS_DIR}/as-pipeline/prompts/dev-agent.md` and use its full contents as this prompt,
    substituting {IMPL}, {BASE}, {PLAN}, and {story-key} with their current values.]
```

After the Task completes: **store the returned agent ID as `DEV_AGENT_ID`**. Read the story file. Verify story status is `review` in sprint-status.yaml. If not, re-dispatch once more (and update `DEV_AGENT_ID` with the new agent ID).

#### Step 5c-iii: Git Commit
Based on `git.commit_frequency`:
- `task` or `story`:
  1. Run `git add -A` to stage implementation changes.
  2. Run `git diff --cached --quiet` to check if anything is staged. If nothing is staged, skip the commit.
  3. Read the "Completion Notes" from the Dev Agent Record section of `{IMPL}/stories/{story-key}.md`.
  4. Compose a concise commit message (≤72 chars) summarizing what was implemented. Use plain language based on the Completion Notes. No prefixes, no story keys, no boilerplate. Do NOT add any `Co-authored-by` or other trailer lines — the commit author must be exclusively the human git user.
  5. Run `git commit -m "{message}"`.
- `epic`: Skip (will commit after all stories in the epic are done — see Step 5f)
- `never`: Skip entirely

#### Step 5c-iv: Adversarial Review
> ⛔ **ORCHESTRATOR RULE:** Do NOT review this story yourself. You MUST dispatch a reviewer sub-agent via the Task tool. Do not mark the story done or proceed to the next story until this sub-agent returns.

Initialize `review_cycles = 0`.

**Review loop** — repeat while story status != `done` AND review_cycles < MAX_REVIEW_CYCLES:

  Increment `review_cycles`.

  Dispatch reviewer sub-agent using the **Task tool**:

  - **Cycle 1 (first review):** dispatch a fresh reviewer sub-agent:
    ```
    Task tool:
      agent_type: general-purpose
      prompt: |
        [Read `{SKILLS_DIR}/as-pipeline/prompts/reviewer-agent.md` and use its full contents as this prompt,
        substituting {IMPL}, {story-key}, {review_cycles}, and {PLAN} with their current values.]
    ```
    **Store the returned agent ID as `REVIEWER_AGENT_ID`.**

  - **Cycle 2+ (subsequent reviews):** **resume** the existing reviewer sub-agent instead of spawning a new one (if your platform supports agent resumption; otherwise dispatch fresh):
    ```
    Task tool:
      resume: {REVIEWER_AGENT_ID}
      prompt: |
        Review cycle {review_cycles}. Re-read the story file at {IMPL}/stories/{story-key}.md
        and sprint-status.yaml. The dev agent has applied fixes since your last review.
        Follow your review process again, focusing only on files changed since the last cycle.
    ```

  After Task completes: read sprint-status.yaml. Check story status.
  If `done`: exit the review loop.
  If `in-progress`: **resume** the dev agent to apply fixes (if your platform supports agent resumption; otherwise dispatch fresh):
    ```
    Task tool:
      resume: {DEV_AGENT_ID}
      prompt: |
        Your implementation was rejected. Read the latest "## Review Cycle {review_cycles} Findings"
        section in {IMPL}/stories/{story-key}.md. Fix ALL HIGH and MEDIUM issues listed there.
        Re-run tests for changed files. Update the Dev Agent Record and set story status to 'review'
        in both the story file and {IMPL}/sprint-status.yaml.
    ```
    Then loop back to review.

**After MAX_REVIEW_CYCLES failed review cycles:**
  Make a judgment call:
  - If remaining issues are ALL LOW severity: set story status to `done`. Decision: "accepted with known issues."
  - Otherwise: set story status to `done` with note "skipped — unresolvable issues."
  
  Append to `{IMPL}/pipeline-report.md` using the "Max Review Cycles Reached" entry format from `{SKILLS_DIR}/as-pipeline/templates/pipeline-report-entries.md`.

#### Step 5c-v: Learning Log Update
After story is `done`: append to `{IMPL}/learning-log.md` (create if missing) using the "Learning Log Entry" format from `{SKILLS_DIR}/as-pipeline/templates/pipeline-report-entries.md`.

#### Step 5c-vi: Follow-up Triage & Surfacing
Read the completed story's **`### Surfaced Follow-ups` block** — the dev agent and reviewer record out-of-scope items there, each with a *proposed* disposition. This block is the primary input. As a backstop, also skim the DAR Plan Deviations / Completion Notes and the latest `## Review Cycle {N} Findings` for any follow-up that should have been surfaced but was only mentioned in prose; pull it into the triage too (and treat the omission from the block as a process miss).

**Core principle: feature-specific, sub-agent-completable work is DONE inside the feature, not documented for later.** "Documenting feature-local work as a follow-up" is the anti-pattern this triage exists to kill. The agent's proposed disposition is a PROPOSAL — you make the final call. For EVERY discrete follow-up item, route it to EXACTLY ONE of the three destinations below. **A follow-up that lives only as prose, or as a "we'll get to it later" note, is a pipeline defect — it MUST land in one of the three.**

**Routing rule** (ask, in order):

0. Is it a discrete piece of **work**, or a **constraint/requirement on how a future story must be authored** (a fixture property its tests must have, an assertion shape it must use, a symbol it must justify against)? If the latter → it is NOT triaged through the tree below: append it to `{IMPL}/learning-log.md` under `Requirements for future stories` (format in `{SKILLS_DIR}/as-pipeline/templates/pipeline-report-entries.md`), naming the exact target story key. Before appending, verify the target key exists in `sprint-status.yaml` with a status that has not yet reached story authoring — agents propose keys from memory and can invent plausible-but-wrong ones; if the key is missing or already authored, resolve the correct target (or route the item as work through the tree below) NOW rather than letting the orphan sweep catch it epics later. Step 5c-i reads the learning log at every story authoring — that read is the ONLY delivery mechanism; do NOT park authoring guidance in `sprint-status.yaml`, the pipeline report, or checkpoint files, where nothing reads it back. The A/B/C tree below is for work only.

1. Is it **sub-agent-completable** (no external action, no human design decision) **AND scoped to THIS feature**?
   - **NO** → **Route C (follow-ups ledger)**, below.
   - **YES** → is it small, related to the *current epic's subject*, and surfaced *now* while the epic is still open and context is fresh?
     - **YES** → **Route A (interleave now)**.
     - **NO** (cross-story — only visible by comparing multiple stories — or large/off-subject enough that injecting it would thrash the current epic; this is the common case for items a *retro* surfaces) → **Route B (cleanup epic)**.

**Route A — Interleave now (a story in the current epic).**
Materialize the item as a new story in the CURRENT epic: pick the next free story number in this epic, write `{epic-num}-{n}-{kebab-title}` into `{IMPL}/sprint-status.yaml` with status `backlog`. The per-story loop (this epic, statuses `backlog`/`ready-for-dev`) will pick it up before this epic's retro — so it is dev'd + reviewed like any story and is `done` before the epic closes. Note it in `{IMPL}/pipeline-report.md` as an interleaved follow-up with its source.

**Route B — Cleanup epic (drained before feature-completion).**
Append the item as a story under the reserved `epic-cleanup:` epic. If `epic-cleanup:` does not yet exist in `development_status`, create it at the END of `development_status` together with `epic-cleanup-retrospective: optional`, status `backlog`. Story key: `cleanup-{n}-{kebab-title}: backlog` (next free `{n}`). The cleanup epic is processed LAST by the per-epic loop (Step 5) and its stories block feature-completion exactly like planned stories. Create the cleanup epic ONLY when an item routes here — a clean feature never grows one.

> **Story creation for follow-up stories (Route A and Route B).** A follow-up story has NO row in `epic-breakdown.md`, so Step 5c-i's traceability extraction does not apply. Instead, write the story file from the follow-up's source — the DAR Plan Deviation / Completion Note or review finding that surfaced it — using the story template: state the concrete change, cite the exact files/lines, set the Testability of each task, and reference the originating story key. Run the Step 5c-i story quality checklist before dispatching the dev sub-agent. Do NOT route a follow-up through correct-course (Step 5c-vii) — it is new in-feature work, not a plan deviation against the architecture.

**Route C — Follow-ups ledger (cannot be done autonomously in-feature).**
Append to the matching top-level key in `{IMPL}/sprint-status.yaml` (create the key if missing). These are rendered into the delivered `{IMPL}/followups.md` at feature completion (Step 6). Pick the key by ownership:

- `blocked_user_actions:` — steps ONLY the USER can complete (external account/credential provisioning, a manual settings change in a third-party console, a hardware/device action). A transient/mocked test stand-in does NOT exempt the action. Optional `bound_code_ref:` records the already-shipped seam awaiting it.
- `deferred_test_debt:` — test cleanup a DIFFERENT feature should sponsor (sibling tests depending on a semantic another feature removed). Sub-agent-completable once the sponsor picks it up; the deferral is about scope ownership, not capability. Optional `baseline_reds:` pins a known-red regression contract.
- `cross_feature_handoffs:` — reusable PRODUCTION infrastructure (a shared helper, base-class hoist, generic utility) a DIFFERENT feature should own. Like `deferred_test_debt:` but for production code; record the `sponsor_feature` and what in THIS feature is blocked until it lands.
- `deferred_design_decisions:` — a design/UX judgment deferred pending data or a human product call. NEVER invent the decision autonomously; record the question, the options considered, and why it is deferred.

Use the exact schemas in `{SKILLS_DIR}/as-sprint-plan/templates/sprint-status.yaml`. Do NOT repurpose one key for another's semantics.

**Doc-correction follow-ups are DONE, not deferred.** A stale or incorrect planning-doc reference (architecture-design.md naming a symbol that doesn't exist, a wrong field name, an infeasible test-plan predicate) is sub-agent-completable and feature-scoped → route it to **interleave** or **cleanup-epic**, never to a ledger key. The fixing story edits the planning doc in place using the correct-course additive convention (`> Updated by Correct Course on {date}: …`) to preserve the audit trail.

**Dedup + reconciliation (keep the ledger and cleanup backlog honest):**
- **Dedup:** before appending, check whether the same item is already present (an existing ledger entry, an open cleanup-epic story, or an interleaved story). If so, do NOT add a duplicate — append the new `source_story` to the existing entry instead. (The same missing helper blocking three stories is ONE handoff with three sources, not three handoffs.)
- **Reconciliation:** when a story (interleaved, cleanup, or a later planned story) RESOLVES a previously-recorded follow-up, remove the corresponding ledger entry / mark the cleanup story `done` so `{IMPL}/followups.md` never ships an item that is already fixed.

#### Step 5c-vii: Correct Course Evaluation
Read the Dev Agent Record: Plan Deviations section from the completed story file.
Evaluate: is there a plan deviation? A deviation is: a wrong assumption in architecture-design.md, a required architectural change, or a scope shift affecting future stories.

- If NO deviation: continue to next story.
- If YES deviation: invoke the correct-course logic inline (do NOT prompt the user):
  1. Follow the same logic as the as-correct-course skill Steps 3–6.
  2. Reset affected future stories to `backlog` in sprint-status.yaml.
  3. Document the change in `{IMPL}/pipeline-report.md`.
  4. Print: `⚠️  Plan deviation detected and handled for {story-key}. Affected stories reset to backlog.`

End of per-story loop.

### 5d: Epic Retrospective
Update sprint-status.yaml: `epic-{N}: in-progress`

Dispatch retrospective sub-agent using the **Task tool**:
```
Task tool:
  agent_type: general-purpose
  prompt: |
    [Read `{SKILLS_DIR}/as-pipeline/prompts/retro-agent.md` and use its full contents as this prompt,
    substituting {N}, {IMPL}, {PLAN}, and the story list with their current values.]
```

**After retro Task completes — apply the retro's dispositions (the retro is a work-generator, not just a report):**

1. **Verify the retro artifact exists.** Confirm `{IMPL}/retros/epic-{N}-retro-*.md` was written. The retro may NOT be silently skipped: if a retro is intentionally not run, an `{IMPL}/retros/epic-{N}-retro-SKIPPED.md` stub with a 2–3 sentence rationale is required instead, and the retro status is set to `skipped`. A bare "skipped" with no artifact is a defect — re-dispatch the retro.

2. **Materialize the retro's `## Follow-up Dispositions`.** Apply the Step 5c-vi routing to each item:
   - items dispositioned **cleanup-epic** → append as `cleanup-{n}-{title}: backlog` stories under `epic-cleanup:` (Route B; create the cleanup epic + `epic-cleanup-retrospective: optional` at the end of `development_status` if absent).
   - items dispositioned **ledger** → append to the matching `blocked_user_actions` / `deferred_test_debt` / `cross_feature_handoffs` / `deferred_design_decisions` key (Route C).
   - items that are **authoring constraints on a specific future story** (routing question 0) → append to `{IMPL}/learning-log.md` as an entry headed `## epic-{N} retro — {date}` containing a `Requirements for future stories` list (same line format as the Learning Log Entry template — a retro has no per-story entry to extend), naming the target story key and validating it per routing question 0.
   - The retro routes cross-story items to cleanup-epic or ledger, NOT to interleave (its epic is closing). Leave `## Cross-Feature Conventions` in the retro file as-is — Step 6 harvests it into `followups.md`.

3. Update sprint-status.yaml: `epic-{N}: done`, `epic-{N}-retrospective: done` (or `skipped` per step 1).

> **`## SMART Action Items for Next Epic`** in the retro is forward *guidance* read by Step 5b when writing the next epic's first story. It is NOT a place to park deferred work — every actual work item must be dispositioned in step 2 above. A SMART item that is really deferred work, not guidance, is a routing miss.
>
> **The LAST retro of the feature has no Step 5b reader.** Whichever retro runs last — the final numbered epic's, or the cleanup epic's if it ran one — addresses its SMART items to an epic that will never exist. Those items are NOT dead: Step 6c harvests them into `{IMPL}/followups.md` as carry-forward guidance for whoever authors the next feature. Do not drop, merge, or summarize them at epic close on the grounds that the epic list is exhausted.

### 5e: End-of-Epic Doc Reconciliation
Planning docs freeze at approval and rot as the implementation diverges (stale symbol names, wrong fields, resolved-but-unrecorded design questions). Rule 1 forbids you editing planning docs yourself, so dispatch a doc-reconciliation sub-agent using the **Task tool**:
```
Task tool:
  agent_type: general-purpose
  prompt: |
    [Read `{SKILLS_DIR}/as-pipeline/prompts/doc-reconciliation-agent.md` and use its full contents as this prompt,
    substituting {N}, {IMPL}, {PLAN}, and {date} with their current values.]
```
This is a flush of the epic's ALREADY-RECORDED deltas (story Plan Deviations + retro Architectural Learnings) into the living docs — NOT a fresh audit, so it is cheap — and the agent prompt carries the full procedure. Running it per-epic means the NEXT epic's stories (authored in 5b/5c-i from these docs) start accurate. A correction a story already made via 5c-vi triage needs no re-doing — 5e touches only still-stale text.

### 5f: Epic Git Commit
If `git.commit_frequency` == `epic`:
1. Run `git add -A` to stage all implementation changes from this epic (including any doc reconciliation edits from 5e).
2. Run `git diff --cached --quiet` to check if anything is staged. If nothing is staged, skip the commit.
3. Compose a concise commit message summarizing what the epic delivered — based on the epic goal from `epic-breakdown.md` and the completed stories. No prefixes, no epic keys, no boilerplate. Do NOT add any `Co-authored-by` or other trailer lines — the commit author must be exclusively the human git user.
4. Run `git commit -m "{message}"`.

End of per-epic loop.

## Step 6: Pipeline Complete

### 6a: Final learning-log sweep (run BEFORE the gate)
The learning log is delivered by being READ at story authoring (Step 5c-i). Once the last story is written there is no further read, so anything still sitting there is orphaned — including entries appended by the *last* story's triage or the *last* retro, which by construction post-date every authoring pass.

Re-read `{IMPL}/learning-log.md` and collect every `Requirements for future stories` line carrying NEITHER a `(consumed by …)` NOR a `(re-triaged …)` annotation. For each, decide:
- **It is work** (something a sub-agent could still do in this feature) → route it through Step 5c-vi now. In practice that means Route B: append a `cleanup-{n}-…` story. The feature is NOT complete — the 6a gate below will send you back to Step 5.
- **It is an authoring constraint on a story this feature will never write** (target story is `done`, descoped, or belongs to a future feature) → it carries out of the feature: it carries out to the `## Carry into the next feature` section of `followups.md`. Hold it verbatim — you hand these to the Step 6c sub-agent in its dispatch, since they exist nowhere else it can read. State each concretely enough for an author with no pipeline context to act on.

Annotate each swept line with `(swept {date} → {disposition})` so a resumed pipeline does not re-route it. If the log has no un-annotated lines, print `✅ Learning log fully consumed.`

### 6b: Feature-completion gate (HARD)
Before declaring the feature complete, re-read `{IMPL}/sprint-status.yaml` and verify that EVERY story — planned, interleaved (Route A), AND cleanup-epic (Route B) — has status `done`, and every epic including `epic-cleanup` (if present) has status `done`. If ANY is not `done`, the feature is NOT complete: return to Step 5 and finish it. **Sub-agent-completable, feature-scoped work is never left for the user** — only the follow-ups ledger (Route C) may carry open items past this gate.

### 6c: Generate the delivered follow-ups doc
`followups.md` is the ONLY artifact that leaves the feature, and its readers work it across LATER sessions with no context from this run — so it is a multi-session work queue, not a report. Rendering it means holding every ledger item, every retro's conventions section, and the 163-line template at once, at the point in the run where your context is most degraded. Dispatch a follow-ups sub-agent using the **Task tool** instead:
```
Task tool:
  agent_type: general-purpose
  prompt: |
    [Read `{SKILLS_DIR}/as-pipeline/prompts/followups-agent.md` and use its full contents as this prompt,
    substituting {IMPL}, {SKILLS_DIR}, and {FEAT} with their current values.
    Carry-out items from the Step 6a learning-log sweep: {the swept carry-out items verbatim, or "none"}.]
```
The agent prompt carries the full procedure — the exhaustive source list, ID assignment, item-kind classification, count reconciliation. Do NOT write `followups.md` yourself from memory of this section; the rendering rules live in that prompt.

**After the Task completes:**
1. **Verify the artifact exists.** Confirm `{IMPL}/followups.md` was written. If not, re-dispatch once.
2. **Record the counts** the agent returned (`{C}` total + per-key) — Step 6d prints them.
3. **Note every non-schema ledger key** the agent reported in `{IMPL}/pipeline-report.md`, so each is either adopted into the sprint-status schema or retired.
4. **Treat any triage miss the agent flags as a pipeline defect** — this doc's work items should be Route-C only. Record it in `{IMPL}/pipeline-report.md`. (Carry-forward guidance and conventions are not work items and are not misses.)

### 6d: Final summary
Print:
```
🎉 Pipeline complete for feature: {FEAT}
   Epics completed: {N}   (incl. cleanup epic: {yes/no})
   Stories completed: {M}   (planned {P} + interleaved {I} + cleanup {CU})
   Plan deviations handled: {K}
   Review cycles total: {R}
   Follow-ups surfaced at feature close: {C} total — {per-key counts, e.g. blocked_user_actions 3, deferred_design_decisions 15, <other-key> 39}
   See {IMPL}/pipeline-report.md for full details, {IMPL}/followups.md to work the follow-ups.
```

The per-key counts printed here MUST match both the YAML and the entries rendered in `followups.md` (Step 6c reconciliation). Printing a count you did not verify against the rendered doc is worse than printing none. Like the doc's own counts, these are point-in-time facts about what the pipeline delivered — not a claim about what is still open once people start working the file.

If `blocked_user_actions:` is non-empty, ALSO print each as a blocked user action requiring USER completion before the feature can be fully verified, with its `since` and `source_story`. Do NOT mark the feature fully shippable while `blocked_user_actions` is non-empty.

If `deferred_test_debt:` or `cross_feature_handoffs:` is non-empty, print each with its `sponsor_feature` — the current feature CAN ship with these unresolved (they are another feature's to resolve). If `deferred_design_decisions:` is non-empty, print each as a product/UX question awaiting a human ruling. If every Step 6c source is empty, print: `✅ No follow-ups surfaced — feature fully closed.`
