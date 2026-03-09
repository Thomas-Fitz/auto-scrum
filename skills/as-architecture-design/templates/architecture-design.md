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
[File naming, class naming, function naming, variable naming for this feature's domain]

### Code Organization
[Where new files go, how they relate to existing structure, test file locations]

### Communication Patterns
[How this feature's components communicate — events, direct calls, message bus. Must be consistent with existing codebase patterns.]
```
[Code example showing the communication pattern]
```

### Anti-Patterns to Avoid
[Known pitfalls relevant to this feature. What NOT to do and why.]

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
