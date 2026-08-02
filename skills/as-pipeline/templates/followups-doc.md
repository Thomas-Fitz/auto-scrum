# Follow-Ups — {FEAT}

**Generated:** {YYYY-MM-DD HH:MM} by as-pipeline at feature completion.
**Feature:** {FEAT}
**Status:** {"All clear — no open follow-ups" | "Shipped with N open follow-up(s)"}

> This document is a **pipeline delivery**, generated from the structured ledger in
> `sprint-status.yaml` plus the epic retros. It contains ONLY work the pipeline could not
> complete autonomously inside the feature — everything sub-agent-completable and
> feature-scoped was done in-feature (interleaved into its epic or drained by the cleanup
> epic). If an item below could have been done autonomously, that is a pipeline defect, not
> a follow-up. Do NOT hand-edit this file to add feature-local work — route that through the
> pipeline instead.
>
> **Every item is listed individually.** Sections state their own count, which must match the
> source in `sprint-status.yaml`. Items are never collapsed into a summary row and never folded
> into a neighbour's bullet — two items that share a subject but differ in who can act on them
> are different items.

---

## User actions required ({N})

Steps ONLY the user can complete — no sub-agent automation path exists (external account /
credential provisioning, a manual settings change in a third-party console, a hardware/device
action). The feature is NOT fully verifiable until these are done.

<!-- One entry per blocked_user_actions item. Omit the section if empty. -->
- **Action:** {action}
  - **Source story:** {source_story}   **Since:** {since}
  - **Impact:** {impact}
  - **Bound code seam (already shipped, awaiting this action):** {bound_code_ref or "—"}

## Cross-feature handoffs ({N})

Reusable **production** infrastructure this feature surfaced that a *different* feature should
own (a shared helper, base-class hoist, generic utility). Sub-agent-completable, but out of
this feature's scope.

<!-- One entry per cross_feature_handoffs item. Omit the section if empty. -->
- **Handoff:** {description}
  - **Source story:** {source_story}   **Sponsor feature:** {sponsor_feature}   **Since:** {since}
  - **Impact / who is blocked:** {impact}

## Deferred test debt ({N})

Test cleanup that belongs to a different feature's sponsor scope (e.g. sibling tests that need
deletion/rewrite because another feature removed a semantic this feature's tests still depend on).

<!-- One entry per deferred_test_debt item. Omit the section if empty. -->
- **Debt:** {debt}
  - **Source story:** {source_story}   **Sponsor feature:** {sponsor_feature}   **Since:** {since}
  - **Impact:** {impact}
  - **Baseline reds (regression contract, if any):** {baseline_reds or "—"}

## Deferred design decisions ({N})

Design / UX judgments deliberately deferred — typically pending data or a human product
call. The pipeline must NOT invent these.

<!-- One entry per deferred_design_decisions item. Omit the section if empty. -->
- **Decision:** {question}
  - **Source story:** {source_story}   **Since:** {since}
  - **Options considered:** {options}
  - **Why deferred:** {rationale}

## Other ledger entries ({N})

Items held under a `sprint-status.yaml` top-level key outside the four-key schema. The pipeline
grew these keys ad hoc during execution; they are rendered here rather than dropped. Each needs a
human call: adopt the key into the sprint-status schema, or retire it and re-route its items.

<!-- One entry per item, grouped by key. Omit the section if no such keys exist. -->
### `{key_name}` ({N})

- **Item:** {the item's primary field, verbatim}
  - **Source story:** {source_story or "—"}   **Since:** {since or "—"}
  - **Remaining fields:** {every other field on the item — do not drop fields you have no slot for}

## Cross-feature conventions ({N})

Durable conventions / anti-patterns this feature taught that likely apply beyond it. Each entry
pairs the convention with a **suggested home** — a human decides whether to fold it into that
skill / prompt / template / test. This is advisory routing, NOT auto-injection.

<!-- One entry per convention surfaced by a retro. Omit the section if empty. -->
- **Convention:** {one-line rule, stated as an enforceable check}
  - **Evidence:** {source story/retro + file:line or symptom}
  - **Suggested home:** {exact skill/prompt/template/test to add it to, and the kind of edit}

## Carry into the next feature ({N})

Forward **guidance**, not work — none of this blocks shipping. Two sources, both of which lose
their in-pipeline reader at feature close:

1. The **last retro's SMART action items.** Every earlier retro's items were consumed when the
   next epic's first story was authored; the last retro addresses an epic that never runs.
2. **Unconsumed learning-log requirements** — authoring constraints aimed at a story this feature
   will never write (target descoped, already done, or belonging to a later feature), including
   any recorded after the last retro ran.

Each item is stated to be actionable by an author with no context from this feature's pipeline.

<!-- One entry per item. Omit the section if both sources are empty. -->
- **Guidance:** {the constraint or action, stated concretely}
  - **Origin:** {retro file + section | learning-log entry N}   **Original target:** {story key or "next epic"}
  - **Why it still matters:** {the failure it prevents, with the evidence that motivated it}
