# Story {epic_num}.{story_num}: {story_title}

Status: ready-for-dev
Repo: {repo}

## Story
As a {role},
I want {action},
so that {benefit}.

## Acceptance Criteria
{For each AC ID from the traceability columns: paste the exact AC text from prd.md, numbered to match AC-N labels}
1. [Exact AC text from prd.md — AC-N]
2. ...

## Tasks / Subtasks
{For each task, check the Testability of its AC from the "Test cases to satisfy" section below and use the matching subtask pattern:}

- [ ] Task 1 (AC: #1, Testability: AUTO)
  - [ ] Subtask 1.1: Write failing test for [specific behavior]
  - [ ] Subtask 1.2: Implement [specific thing] to make test pass
  - [ ] Subtask 1.3: Refactor
- [ ] Task 2 (AC: #2, Testability: AGENT-REVIEW)
  - [ ] Subtask 2.1: Implement [specific change]
  - [ ] Subtask 2.2: Verify build passes
- [ ] Task 3 (AC: #3, Testability: NONE)
  - [ ] Subtask 3.1: Remove/update [specific thing]
  - [ ] Subtask 3.2: Verify build/lint passes — confirm [target] no longer exists

## Dev Notes
**Architecture:** [Paste the exact architecture-design.md section content from the Design Refs — not a link, the actual text/code snippets/before-after examples]
**Anti-patterns to avoid:** [Paste the Anti-Patterns to Avoid section from architecture-design.md if the story touches any of those areas]
**Files to modify:** [Exact file paths, no vague references]
**Files to create:** [Exact file paths]
**Test cases to satisfy:** [For each test scenario from traceability columns: paste the full GIVEN-WHEN-THEN scenario from test-plan.md, including its test type (unit/integration/e2e) and testability level (AUTO / AGENT-REVIEW / NONE). For AGENT-REVIEW ACs, note what the reviewer agent should inspect. For NONE ACs, note what build/lint check confirms completion.]
**Testing approach:** [Framework, test file locations, what to assert]
**Edge cases:** [Specific edge cases to handle]
**Integration points:** [What this story touches that affects other components]

**Conditional Dev Notes subsections** — add a subsection ONLY when its trigger applies; populate with story-specific values (do NOT paste the guide's prose). Rule + trigger for each is in `{SKILLS_DIR}/as-pipeline/reference/story-authoring-guide.md` → "Conditional Dev Notes subsections":
- *Test-helper extraction* — any test helper used across ≥2 test files goes in a shared module, never duplicated.
- *Semantic-removal test sweep* — if this story DELETES/REPLACES a behavior/API/semantic: search the test dir for the symbol, its user-facing strings, and its unique state shape; cite hit counts.
- *Test-filter pre-validation* — if any Subtask runs the test runner with a name/pattern filter: pre-validate with the runner's list/dry-run mode and cite the literal match count.
- *Seam-name + namespace pre-validation* — if prescribing a test seam or test id/namespace prefix: verify both against the codebase; cite the search.
- *`### Cross-Story Literal Contracts`* — if this story is producer/consumer of a literal-string contract with a sibling: add the subsection with the verbatim literal, producer/consumer sites, uniqueness count.
- *Regression-coupling hypothesis verification* — if any Task claims "feature regressed test X" / "X caused by Y": search to verify before recording; DAR cites the search.
- *Pure-deletion Plan Deviations skeleton* — if the work is deletion/replacement with no behavior delta: pre-extract the skeleton into a Subtask for verbatim paste into the DAR.

### Previous Learnings
{First story of each epic (N>1): paste SMART action items from previous epic retro.
All other stories: paste relevant entries from learning-log.md, or "No relevant prior learnings."}

### References
- [Source: architecture-design.md#{Section}]
- [Source: prd.md#FR-{N}]
- [Source: test-plan.md#AC-{N}]
- [Source: epic-breakdown.md#Epic {N}]

## Dev Agent Record
### Agent Model Used
### Completion Notes
### File List
### Plan Deviations
{What diverged from the story file, why, and the resolution. For pure-deletion stories, the entry MUST explicitly state `no replacement {function/test/helper}` and identify where the equivalent behavior now lives (or that it is intentionally gone) — this preempts a reviewer defensive-search on deletions. If a `Plan Deviations skeleton (pre-extracted)` Subtask exists, paste it here verbatim and amend each line with actuals.}
### Destructive Operation Requests
{List any moment during implementation where a revert/deletion/reset seemed necessary. For each: the files involved, the exact command considered, why it seemed necessary, and the resolution (USER-authorized / denied / fixed forward instead). MUST be "None." if no such moments occurred. Agents MUST NEVER revert or delete without explicit USER authorization in the current conversation.}
### Surfaced Follow-ups
{Out-of-scope work this story surfaced but did NOT do. Boundary: you FIX what is inside this story's tasks; you SURFACE what is outside them. Do NOT sprawl into adjacent files to "while I'm here" fix things — surface them here instead. The orchestrator (Step 5c-vi) reads this block and routes each item; an item left only as prose elsewhere in the DAR will be missed, so put it HERE.

For each surfaced item, one entry:
- **Item:** <one line — what's wrong / what's needed>  `<file>:<line>`
  - **Out-of-scope because:** <why it isn't part of this story's tasks>
  - **Proposed disposition:** `interleave` (feature-scoped, sub-agent-doable, related to THIS epic, do it now) | `cleanup-epic` (feature-scoped, sub-agent-doable, but cross-cutting / off-subject) | `ledger:<key>` (needs a user/external action, another feature, or a human design call — key ∈ blocked_user_actions / deferred_test_debt / cross_feature_handoffs / deferred_design_decisions)
  - **Rationale:** <one line>

Recurring classes worth scanning for before you write "None.": stale/incorrect planning-doc reference, dead/orphaned code from a superseding path, a test helper now duplicated across files, a behavior gap you deferred mid-story, a producer-only contract literal lacking a consumer test, an external dependency awaiting provisioning. The orchestrator makes the final routing call — your disposition is a proposal. MUST be "None." if there are genuinely no surfaced follow-ups.}
