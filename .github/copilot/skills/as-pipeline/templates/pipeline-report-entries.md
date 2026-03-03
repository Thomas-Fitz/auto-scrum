# Pipeline Report Entry Formats

Use these formats when appending entries to `{IMPL}/pipeline-report.md` and `{IMPL}/learning-log.md`.
Substitute all `{placeholder}` values with current runtime values before writing.

---

## Max Review Cycles Reached (append to pipeline-report.md)

```markdown
## Story {story-key} — Max Review Cycles Reached
**Date:** {date}
**Decision:** [accepted with known issues / skipped]
**Rationale:** [issues that could not be resolved in MAX_REVIEW_CYCLES cycles]
**Known Issues:** [list]
```

---

## Learning Log Entry (append to learning-log.md)

```markdown
## {story-key} — {date}
**Story:** {story-title}
**Discoveries:** {from Dev Agent Record: Plan Deviations section}
**Architectural Insights:** {key decisions made during implementation}
**Deviations from Plan:** {what changed vs. original design.md}
```
