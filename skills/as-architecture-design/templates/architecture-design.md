# Architecture Design: {feature-name}

**References:** [prd.md](./prd.md)[, ux-design.md](./ux-design.md)] _(include ux-design.md only if it exists)_
**Status:** Draft — Pending Approval

---

## 1. Technology Decisions
| Decision | Choice | Rationale | Existing Pattern? | Alternatives Considered |
|----------|--------|-----------|-------------------|------------------------|

## 2. System & Component Architecture
[Mermaid diagram showing components, data flow, boundaries, and how this feature integrates with existing components]

### Components
[Each major component: responsibility, interface, dependencies, whether new or modified]

## 2A. UX Implementation Mapping
[REQUIRED when `ux-design.md` exists for this feature. If there is no UX spec, write "N/A — no ux-design.md for this feature."]

`ux-design.md` is a BINDING input: every surface, focus rule, visual state, confirm/cancel decision, and input-parity commitment in it is a hard requirement this architecture must implement. This section is the architect's forcing function — it pins a concrete implementation home (component, data binding, event, or state machine) to each binding UX decision so the experience is not dropped between the UX spec and the code. The sprint-plan and test-plan UX coverage gates flag exactly this omission downstream; close it here instead. Do NOT restate the UX prose — map each decision to its code shape.

| UX decision (ux§ ref) | User-experience requirement | Architectural mechanism that implements it (component / binding / event / state) |
|-----------------------|-----------------------------|----------------------------------------------------------------------------------|
| ux§3.x _(surface)_ | _(when it appears / dismisses / whether it blocks input)_ | _(which component/layer owns it; how it is shown/hidden)_ |
| ux§5.1 Focus & keyboard model | _(initial focus, tab/nav order, wrap-vs-clamp, restore-on-close)_ | _(focus-routing mechanism; where initial-focus and restore are set)_ |
| ux§5.2 Visual states | _(default / hover / focus / selected / disabled / error)_ | _(the state source that drives each — view-model field, style state, etc.)_ |
| ux§5.3 Confirm/cancel/destructive | _(confirm / cancel / destructive actions)_ | _(input bindings; which component owns the confirm dialog)_ |
| ux§5.4 Empty/loading/error states | _(what each state shows and when)_ | _(the state source and component that renders each)_ |
| ux§6 Accessibility minimums | _(parity across input devices, contrast, labels/narration the spec commits to)_ | _(the shared path that guarantees parity; where labels/roles are set)_ |

Cover every binding ux-design section (add rows for transitions §5.5 and any other commitments the spec makes). For an Open Design Question (ux§8) the architect must NOT invent an answer — list it as deferred and design no further than the spec commits.

## 3. Data Models
[Entity definitions with fields, types, constraints, and relationships. Mermaid ERD if helpful. Note whether models are new or modifications to existing ones.]

## 4. API Contracts
[Endpoint definitions: method, path, request shape, response shape, error codes. Reference existing API conventions.]

## 5. Novel Patterns
[Any new patterns being introduced that don't have standard solutions in the codebase. If none, mark N/A.]

### [Pattern Name]
- **Purpose:** [What problem this pattern solves]
- **Why existing patterns are insufficient:** [What was tried or considered and why it doesn't work]
- **Components:** [List each component involved and its responsibility]
- **Data Flow:** [How data moves between components — sequence diagram if complex]
- **State Management:** [How state is tracked and transitioned — state machine diagram if applicable]
- **Edge Cases & Failure Modes:** [What can go wrong and how the pattern handles it]
- **Implementation Guide:**
```
[Concrete code example showing the pattern in action — enough for a dev agent to implement without ambiguity]
```
[Repeat for each novel pattern]

## 6. Cross-Cutting Concerns
[Mandatory patterns that all code for this feature must follow. Each must include a concrete code example.]

### Error Handling
[Strategy: try-catch, result objects, signal-based, global handler. What's recoverable vs fatal.]
```
[Code example showing the error handling pattern]
```

### Logging & Debug
[Log levels, format, destination. What gets logged at each level.]
```
[Code example showing the logging pattern]
```

### Event/Signal Conventions
[Signal naming convention, event payload structure, sync vs async. How components subscribe and unsubscribe.]
```
[Code example showing signal declaration and emission]
```

### Configuration & Tuning
[Where tunable values live (constants file, config, environment variables, data-driven definitions). How they are structured and accessed.]

## 7. Implementation Patterns
[Consistency rules that all agents must follow when implementing this feature. Every pattern must include a concrete code example.]

### Naming Conventions
[File naming, class naming, function naming, variable naming for this feature's domain. Beyond matching codebase casing/prefix conventions, names must be intention-revealing: full words over abbreviations, and a name that tells a junior engineer with no codebase context what the thing does or is. Name this feature's domain vocabulary here (the nouns/verbs its identifiers should be built from) so all agents use the same terms.]

### Code Organization
[Where new files go, how they relate to existing structure, test file locations]

### Communication Patterns
[How this feature's components communicate — events, direct calls, message bus. Must be consistent with existing codebase patterns.]
```
[Code example showing the communication pattern]
```

### Anti-Patterns to Avoid
[Known pitfalls relevant to this feature. What NOT to do and why.]

### Shared Base-Class Contract
[REQUIRED when this feature has TWO OR MORE implementations on a shared base class / interface / canonical reference (e.g. N endpoints on one base controller, N components on one base, N handlers on one interface). This is the single defense against per-implementer DRIFT — the reviewer reviews one sibling at a time and cannot see that 8 of 9 siblings diverged from the 9th. Name the base and the canonical reference implementer, then pin the contract EVERY sibling must honor. If the feature has no shared-base family, write "N/A — no shared base-class family."]

- **Base / interface:** [name + file]
- **Canonical reference implementer:** [the sibling other implementers must match, + file]
- **Required overrides — signature AND access level** (drift in either is a defect):

  | Member | Signature | Access (public/protected/private) | Mandatory? |
  |--------|-----------|-----------------------------------|------------|

- **Mandatory lifecycle behaviors** [behaviors every sibling MUST perform, not just declare — e.g. "in `init`, register the cleanup handler"; "call `super` before returning"]:
  1. [...]
- **Per-implementer configuration** [config each sibling sets, and the allowed values — make the matrix explicit so a sibling's value is a deliberate choice, not a copy-paste accident]:

  | Sibling | [config A] | [config B] |
  |---------|-----------|-----------|

## 8. Implementation Notes
[Key constraints and decisions the dev agent must follow. File paths to create/modify. Sequencing guidance.]

## 9. Codebase Impact

### Files Modified
[List of existing files that will be changed, with brief description of what changes]

### Files Created
[List of new files to be created, with their purpose]

### Files Deleted
[Any files to be removed, with rationale. If none: N/A]

## 10. Pattern Alignment
[How this design follows established codebase conventions. Reference specific existing files/components as examples.]

### Patterns Followed
| Area | Existing Pattern | How This Feature Follows It | Reference |
|------|-----------------|----------------------------|-----------|

## 11. Deviations & Justifications
[Any place where this design departs from existing patterns. Required for each deviation identified in Step 4.]

### Deviations
| Area | Existing Pattern | Proposed Deviation | Justification |
|------|-----------------|-------------------|---------------|
