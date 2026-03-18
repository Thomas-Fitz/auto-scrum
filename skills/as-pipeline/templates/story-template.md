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
