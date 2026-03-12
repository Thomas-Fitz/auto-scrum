# Test Plan: {feature-name}

**References:** [prd.md](./prd.md), [architecture-design.md](./architecture-design.md)
**Status:** Draft — Pending Approval
**Test Framework:** [from project-context or inferred from codebase scan]
**Existing Coverage:** [summary of existing test files for this feature, if any]

---

## 1. Test Strategy
[Overall approach: what types of tests (unit/integration/E2E), what tools, coverage targets]
[Note: Indicate which ACs are already covered by existing tests and which are new]

## 2. Acceptance Criteria Coverage Matrix

| AC ID | Description | Priority | Testability | Test Type | Scenario Name | Existing? |
|-------|-------------|----------|-------------|-----------|---------------|-----------|
| AC-1  | ...         | P0       | AUTO        | ...       | ...           | No        |

_Every AC from prd.md must have at least one row. Mark "Yes" if already covered by existing tests._

**Testability values:**
- `AUTO` — automated test required (code behavior, business logic, APIs, data integrity)
- `AGENT-REVIEW` — no automated test; reviewer agent verifies by inspection (documentation updates, content changes, config-only changes, visual/structural output)
- `NONE` — not testable by test or inspection; only build/lint/compile verification (dead code removal, unused import cleanup, comment-only changes)

## 3. Unit Tests

[For each unit test scenario: function/class under test, inputs, expected outputs, edge cases. Only list new scenarios not covered by existing tests.]

```
SCENARIO: [Name]
  GIVEN [precondition]
  WHEN [action]
  THEN [expected outcome]
  AC: [AC-N]
  PRIORITY: [P0-P3]
  TYPE: unit
```

## 4. Integration Tests

[For each integration test: components under test, setup/teardown, expected state changes. Only list new scenarios.]

```
SCENARIO: [Name]
  GIVEN [precondition]
  WHEN [action]
  THEN [expected outcome]
  AC: [AC-N]
  PRIORITY: [P0-P3]
  TYPE: integration
```

## 5. End-to-End Tests

[For each E2E test case: user journey tested, preconditions, steps, expected system state. Only list new scenarios.]

```
SCENARIO: [Name]
  GIVEN [precondition]
  WHEN [action]
  THEN [expected outcome]
  AC: [AC-N]
  PRIORITY: [P0-P3]
  TYPE: e2e
```

## 6. Edge Cases & Negative Tests

[Error scenarios, boundary conditions, invalid inputs, impossible states, recovery from failures. Each in GIVEN-WHEN-THEN format.]

## 7. Regression Impact

### Existing Files Affected
| File | Existing Tests? | Risk | Regression Scenario Needed? |
|------|----------------|------|-----------------------------|

### Regression Scenarios
[Scenarios that verify existing behavior is preserved after this feature's changes are integrated]

## 8. Pass/Fail Criteria

- All P0 scenarios pass: **required for merge**
- All P1 scenarios pass: **required for merge**
- All P2 scenarios pass: **required for release**
- P3 scenarios: best effort
- No flaky tests (any test that fails intermittently must be fixed or removed)
- Code coverage ≥ [X]%: [target from project-context or 80% default]
