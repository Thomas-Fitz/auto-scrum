# Story Authoring Guide

Read by the orchestrator (as-pipeline Step 5c-i) when instantiating a story from
`templates/story-template.md`. It holds the standing rules and conditional Dev Notes subsections
that would otherwise be copied verbatim into every story file — kept here so they are NOT
re-read by the dev and reviewer agents on every cycle (token hygiene). The template carries only
the per-story field skeleton; this guide tells you which conditional subsections to add and what
to put in them.

**How to use it:** add a subsection to the story's Dev Notes ONLY when its trigger applies. Each
is a real per-story slot when triggered — populate it with story-specific values; do NOT paste
this guide's prose into the story file. The typical story trips none of these.

---

## Conditional Dev Notes subsections

### Test helpers must be extracted, not duplicated (trigger: a test helper is used in >1 test file)
Any test helper used in more than one test file — fixtures, factory/builder functions, RAII or
setup/teardown utilities, file-scope helpers, named constants — MUST live in a shared sibling
module (a test-helpers file the suite imports), not be copy-pasted across test files. If you find
yourself writing "mirror of the helper in X" — stop and extract. Duplicated helper bodies drift
silently: a fix applied to one copy and not the others produces tests that disagree about the same
contract. Name the shared module path in a Subtask.

### Semantic-removal test sweep (trigger: this story DELETES or REPLACES a behavior, API, or semantic)
Before declaring the removal complete, search the test directory for THREE signals: (a) the deleted
symbol(s) by name, (b) the user-facing string(s) the removed semantic produced (log messages, error
copy, AC text), (c) any state shape unique to the removed path. Delete or rewrite EVERY hit. A
Subtask must explicitly cite the search commands run and the hit count for each. Test *names* are an
unreliable index when deleting — what a test ASSERTS is the reliable index, so search bodies, not
just filenames. (A name-only enumeration commonly misses sibling tests that resurface months later
as "regressions" and force a cleanup story.)

### Test-filter pre-validation (trigger: any Task runs the test runner with a name/pattern filter)
Pre-validate every filter at story-write time. For each filter string the story will use, run the
test runner in its list/dry-run mode and record in a Subtask: (a) the literal match count — never a
hand-derived estimate from substring math, (b) a brief summary of the matched test names/namespaces.
A filter that matches zero tests, or matches the wrong tests via substring collision, reports a clean
exit with no failures — the sweep silently "passes" without ever running the intended tests. A Subtask
that runs a filtered sweep MUST cite the pre-validated match count.

### Seam-name + namespace pre-validation (trigger: this story prescribes a test seam name or a test id/namespace prefix)
Verify both against the codebase at story-write time. For each prescribed test seam (an accessor/setter
the test calls to observe internal state — e.g. a `*ForTesting` getter), confirm it exists at
`<file>:<line>`, OR that it is to-be-created by this story (name it in a Subtask). For each test
id/namespace prefix the new tests will register under, confirm it matches the project's real
registration convention (check an existing sibling test). A Subtask must cite the result. An unverified
seam name forces a silent dev-time substitution; a wrong namespace prefix registers the test where the
regression sweep never looks.

### Cross-story literal-string contracts (trigger: this story is the PRODUCER or CONSUMER of a literal string a sibling story matches on)
When a producer story embeds a literal string in production code (a log line, error message, user-facing
copy) that a consumer story matches against via a substring/contains test assertion, the literal becomes
a public API surface between the two stories — byte-identity is load-bearing. Both stories MUST record
the contract in a `### Cross-Story Literal Contracts` Dev Notes subsection with this shape per literal:
- **Literal:** `<verbatim string, character-for-character>`
- **Producer site:** `<file>:<line>` (planned) — `<sibling story key>` (producer)
- **Consumer site(s):** `<file>:<line>` per matcher — `<sibling story key>` (consumer)
- **Uniqueness:** search count across the source tree at plan time (target: 1 production occurrence + N
  matcher occurrences; if higher, narrow the literal until uniqueness holds)
- **Dev-time verification (CONSUMER stories only):** a Subtask that re-searches the producer site after
  the producer story has landed and confirms byte-identity; cite the command and matched line.

### Regression-coupling hypothesis verification (trigger: a Task claims "this feature regressed test X" or "X fails because of file Y")
Every coupling hypothesis MUST be verified at dev time by searching the failing test file(s) for the
alleged-coupling symbol set (function names, class names, log strings, import paths) BEFORE the
hypothesis is recorded as the explanation. The DAR entry MUST cite the search: command run, hit count,
and either line numbers (if non-zero) or "zero hits — hypothesis disproved, re-investigated; actual
cause: ..." (if zero). A coupling claim without a search citation is a planning defect — the reviewer
will REJECT. A 5-second search proving the hypothesis wrong saves a long root-cause cycle on the wrong
file.

### Pure-deletion / replacement Plan Deviations (trigger: the story's implementation work is removing or swapping code with no behavior delta)
For deletion/replacement stories, most of the DAR's `### Plan Deviations` content is predictable at
story-write time. Pre-extract it into a Subtask labeled `Plan Deviations skeleton (pre-extracted)` so
the dev agent pastes it verbatim and amends only with actuals. Cover: the verbatim literal strings
touched (with file:line), the include/import churn per file, the stale-comment sweep result (which
narrative comments were touched vs. left and why), and predicted-vs-actual counts (N tests/files
expected vs. M actual, delta explained). The entry MUST also state `no replacement {override/test/helper}`
and where the equivalent behavior now lives (or that it is intentionally gone) — this preempts the
reviewer's defensive search on every deletion story.
