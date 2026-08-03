# Follow-Ups — {FEAT}

**Generated:** {YYYY-MM-DD HH:MM} by as-pipeline at feature completion.
**Feature:** {FEAT}
**At feature close:** {"All clear — no follow-ups surfaced" | "Shipped with N follow-up(s) surfaced"}

> **This is a working document.** It was generated once, at feature close, and is now owned by
> whoever works the items — across as many sessions as it takes. **Tick the boxes, append notes,
> and record resolutions as you go.** That is what this file is for.
>
> What you must NOT do is hand-edit it to add *feature-local* work — work a pipeline sub-agent
> could have done inside the feature. Route that through the pipeline instead. Everything listed
> here is work the pipeline could not complete autonomously; everything sub-agent-completable and
> feature-scoped was already done in-feature (interleaved into its epic or drained by the cleanup
> epic). If an item below could have been done autonomously, that is a pipeline defect.
>
> **Counts are point-in-time.** Every `(N surfaced at feature close)` is a historical fact about
> what the pipeline delivered — it is NOT a running tally of what is open. Do not update counts as
> you tick items off; they must stay checkable against `sprint-status.yaml`.
>
> **Every item is listed individually.** Items are never collapsed into a summary row and never
> folded into a neighbour's bullet — two items that share a subject but differ in who can act on
> them are different items.

---

## How to read and update this file

Items come in three kinds, distinguished by what "finished" actually means:

| Kind | Finished when | Marker |
|---|---|---|
| **Task** | the work is done and the check passes | `- [ ]` + **Done when:** |
| **Decision** | a ruling is recorded somewhere durable | `- [ ]` + **Decided when:** |
| **Guidance** | never — it is read and consumed by an author | no checkbox; section-level **Consumed by:** |

**IDs are permanent.** Each item carries `{FEAT}-FU-NN`. Cite it in commit messages, handoffs, and
blocked-on notes. Resolved items keep their number and stay in place — nothing is ever renumbered,
reordered, or deleted. New items take the next free number.

**Status tags** go inline on the item's title line, and only when they apply:

- `⛔ BLOCKED: {what it is waiting on}` — attempted, hit a wall. Saves the next session from
  re-attempting the same wall.
- `🚫 WON'T DO: {reason}` — decided against. Tick the box; the reason is the resolution.

**Notes accrue.** Add a dated line under **Notes:** whenever you make partial progress. Half-done
work that leaves no trail is the failure mode this file exists to prevent.

**On completion**, tick the box and add a **Resolved:** line stating what was done, where, and how
it was verified.

---

## User actions required ({N} surfaced at feature close)

**Kind: Task.** Steps ONLY the user can complete — no sub-agent automation path exists (external
account / credential provisioning, a manual settings change in a third-party console, a
hardware/device action). The feature is NOT fully verifiable until these are done.

<!-- One entry per blocked_user_actions item. Omit the section if empty. -->
- [ ] **{FEAT}-FU-{NN} — {action}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Why:** {impact — what stays broken or unverifiable until this is done}
  - **Context:** `{source_story}` · surfaced {since} · bound code seam (shipped, awaiting this action): {bound_code_ref or "—"}
  - **Done when:** {an observable check — a command that passes, a state you can look at. If the feature's evidence does not support one, write verbatim: *not determinable at feature close — establish a check before starting.*}
  - **Notes:**
  <!-- On completion, tick the box above and add: -->
  <!-- - **Resolved:** {date} — {what was done, where, how verified} -->

## Cross-feature handoffs ({N} surfaced at feature close)

**Kind: Task.** Reusable **production** infrastructure this feature surfaced that a *different*
feature should own (a shared helper, base-class hoist, generic utility). Sub-agent-completable, but
out of this feature's scope.

<!-- One entry per cross_feature_handoffs item. Omit the section if empty. -->
- [ ] **{FEAT}-FU-{NN} — {description}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Why:** {impact — who is blocked, or what stays duplicated, until this lands}
  - **Context:** `{source_story}` · sponsor feature: {sponsor_feature} · surfaced {since}
  - **Done when:** {observable check, or the *not determinable* sentence}
  - **Notes:**

## Deferred test debt ({N} surfaced at feature close)

**Kind: Task.** Test cleanup that belongs to a different feature's sponsor scope (e.g. sibling
tests that need deletion/rewrite because another feature removed a semantic this feature's tests
still depend on).

<!-- One entry per deferred_test_debt item. Omit the section if empty. -->
- [ ] **{FEAT}-FU-{NN} — {debt}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Why:** {impact}
  - **Context:** `{source_story}` · sponsor feature: {sponsor_feature} · surfaced {since}
  - **Baseline reds (regression contract, if any):** {baseline_reds or "—"}
  - **Done when:** {observable check — usually the suite/command that must go green, or the *not determinable* sentence}
  - **Notes:**

## Other ledger entries ({N} surfaced at feature close)

**Kind: Task.** Items held under a `sprint-status.yaml` top-level key outside the four-key schema.
The pipeline grew these keys ad hoc during execution; they are rendered here rather than dropped.
Each also needs a schema call: adopt the key into the sprint-status schema, or retire it and
re-route its items.

<!-- One entry per item, grouped by key. Omit the section if no such keys exist. -->
### `{key_name}` ({N} surfaced at feature close)

- [ ] **{FEAT}-FU-{NN} — {the item's primary field, verbatim}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Context:** `{source_story or "—"}` · surfaced {since or "—"}
  - **Remaining fields:** {every other field on the item — do not drop fields you have no slot for}
  - **Done when:** {observable check, or the *not determinable* sentence}
  - **Notes:**

## Deferred design decisions ({N} surfaced at feature close)

**Kind: Decision.** Design / UX judgments deliberately deferred — typically pending data or a human
product call. The pipeline must NOT invent these, and must not invent their answers.

<!-- One entry per deferred_design_decisions item. Omit the section if empty. -->
- [ ] **{FEAT}-FU-{NN} — {short title}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Question:** {question}
  - **Context:** `{source_story}` · surfaced {since}
  - **Options considered:** {options}
  - **Why deferred:** {rationale}
  - **Decided when:** a ruling — adopt / reject / defer again with a date — is recorded in {the durable location that should hold it, e.g. a design doc, ADR, or the next feature's planning doc}
  - **Notes:**
  <!-- On completion, tick the box above and add: -->
  <!-- - **Resolved:** {date} — {the ruling}, recorded in {where} -->

## Cross-feature conventions ({N} surfaced at feature close)

**Kind: Decision.** Durable conventions / anti-patterns this feature taught that likely apply
beyond it. Each pairs the convention with a **suggested home** — a human decides whether to fold it
in. This is advisory routing, NOT auto-injection: the decision is adopt-into-that-home, or reject
with a reason.

<!-- One entry per convention surfaced by a retro. Omit the section if empty. -->
- [ ] **{FEAT}-FU-{NN} — {one-line rule, stated as an enforceable check}**  {optional ⛔ BLOCKED: … or 🚫 WON'T DO: …}
  - **Evidence:** {source story/retro + file:line or symptom}
  - **Suggested home:** {exact skill/prompt/template/test to add it to, and the kind of edit}
  - **Decided when:** the convention is folded into that home, or rejected with a recorded reason
  - **Notes:**

## Carry into the next feature ({N} surfaced at feature close)

**Kind: Guidance.** Forward guidance, not work — none of this blocks shipping, and none of it has a
completion event, so these items carry no checkboxes. They are consumed once, by whoever authors
the next feature. Two sources, both of which lose their in-pipeline reader at feature close:

1. The **last retro's SMART action items.** Every earlier retro's items were consumed when the
   next epic's first story was authored; the last retro addresses an epic that never runs.
2. **Unconsumed learning-log requirements** — authoring constraints aimed at a story this feature
   will never write (target descoped, already done, or belonging to a later feature), including
   any recorded after the last retro ran.

Each item is stated to be actionable by an author with no context from this feature's pipeline.

**Consumed by:** _{feature name + date — filled in by whoever authors the next feature. If only
some items applied, say which and why the rest were dropped.}_

<!-- One entry per item. Omit the section if both sources are empty. -->
- **{FEAT}-FU-{NN} — {the constraint or action, stated concretely}**
  - **Origin:** {retro file + section | learning-log entry N} · original target: {story key or "next epic"}
  - **Why it still matters:** {the failure it prevents, with the evidence that motivated it}
