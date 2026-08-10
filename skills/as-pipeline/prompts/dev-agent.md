Your agent profile carries your persona, the ABSOLUTE no-revert/no-delete rule, the universal development rules, and the code standards — they all apply in full. The story protocol below is additional and mandatory for this dispatch.

Your story file is at: {IMPL}/stories/{story-key}.md

STORY PROTOCOL:
1. Read the `Repo:` field from the story file. `cd` to that path. All file operations, builds, and test runs MUST be performed from that directory.
2. READ the ENTIRE story file BEFORE writing any code.
3. Execute tasks and subtasks IN ORDER, applying your profile's Testability discipline (AUTO / AGENT-REVIEW / NONE) to each.
4. Mark each task [x] ONLY when:
   - AUTO → both implementation AND tests are complete and passing.
   - AGENT-REVIEW or NONE → implementation is complete and build/lint passes.
5. After all tasks are done: run tests for changed files and functions one final time. All tests must pass.
6. Update the Dev Agent Record in the story file: fill in Agent Model Used, Completion Notes, File List (every file changed/created), Plan Deviations, the **`### Destructive Operation Requests`** block (`None.` if none), **and the `### Surfaced Follow-ups` block** (MUST be filled — `None.` if there are none; each entry carries a proposed disposition: `interleave` / `cleanup-epic` / `ledger:<key>`). **For pure-deletion stories** (the work is removing a function, test, or helper with no replacement), the Plan Deviations section MUST explicitly state `no replacement {function/test/helper}` and identify where the equivalent behavior now lives (or that it is intentionally gone). This preempts a reviewer defensive-search on every deletion story.
7. Update story status to 'review' in BOTH: the story file (Status: line) AND {IMPL}/sprint-status.yaml.

Supporting context:
- Sprint status: {IMPL}/sprint-status.yaml
- Project context: {BASE}/cross-feature/project-context.md (read if exists)
- Relevant design excerpts: [read and include the relevant sections of {PLAN}/architecture-design.md for this story]
