# Quick-Dev Story: {STORY_KEY}

Status: ready-for-dev
Repo: {repo}

## Story
As a developer,
I want to {change description from REQUIREMENTS_SUMMARY},
so that {why from REQUIREMENTS_SUMMARY}.

## Acceptance Criteria
{List each AC from REQUIREMENTS_SUMMARY, numbered to match AC-1, AC-2, etc.}

## Tasks / Subtasks
{For each file in "Files to modify" / "Files to create" from DESIGN_SUMMARY, create a task.
 AC numbers, story keys, and requirement IDs exist ONLY in this file — they must never appear in source code or code comments.
 Assign each task's testability from the AC testability in TEST_SUMMARY (not re-derived):
 - AUTO → use TDD subtasks: write the failing test for the matching scenario, implement, refactor
 - AGENT-REVIEW → implement and verify build (doc/config/copy changes)
 - NONE → remove and verify build/lint (dead code / unused imports)}

## Dev Notes
**Architecture:** {Implementation approach from DESIGN_SUMMARY}
**Naming:** {Naming from DESIGN_SUMMARY — the identifiers this change introduces}
**Anti-patterns to avoid:** {Pattern deviations from DESIGN_SUMMARY, framed as what to avoid — or "None"}
**Files to modify:** {from DESIGN_SUMMARY}
**Files to create:** {from DESIGN_SUMMARY, or "None"}
**Testing approach:** {Test types + test file locations from TEST_SUMMARY}
**Test Scenarios:** {Paste the GIVEN-WHEN-THEN scenarios from TEST_SUMMARY, each tagged with its AC-N and TYPE. These are the behaviors the dev agent must satisfy and the reviewer verifies against.}
**Edge cases:** {from DESIGN_SUMMARY}
**Integration points:** {Integration risks from DESIGN_SUMMARY}

### Previous Learnings
N/A — as-quick-dev session

### References
- Derived from as-quick-dev session: Requirements Summary, Design Summary, and Test Summary above

## Dev Agent Record
### Agent Model Used
### Completion Notes
### File List
### Plan Deviations
