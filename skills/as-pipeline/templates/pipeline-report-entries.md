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
**Deviations from Plan:** {what changed vs. original architecture-design.md}
**Requirements for future stories:** {omit this line if none}
- `{target-story-key}`: {the constraint that story's authoring must satisfy — a fixture property, an assertion shape, a symbol to justify — stated concretely enough to act on without re-reading this story} (source: {story-key})
```

The `Requirements for future stories` list is directive, not descriptive: each item is addressed to
the named target story and is consumed when Step 5c-i authors it (the story quality checklist
verifies incorporation). Route follow-up items here — via Step 5c-vi routing question 0 — whenever
they constrain HOW a future story must be written rather than adding schedulable work.
