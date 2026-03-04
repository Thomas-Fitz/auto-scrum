# Test Plan: {feature-name}

**References:** [prd.md](./prd.md), [architecture-design.md](./architecture-design.md)
**Test Framework:** [from project-context or inferred from codebase scan]
**Existing Coverage:** [Summary of existing test files for this feature, if any]

---

## 1. Test Strategy
[Overall approach: what types of tests (unit/integration/E2E), what tools, coverage targets]
[Note: Indicate which ACs are already covered by existing tests and which are new]

## 2. Acceptance Criteria Coverage Matrix
| AC ID | Description | Test Type | Test Case Name | Pass Condition | Existing? |
|-------|-------------|-----------|----------------|----------------|-----------|
| AC-1  | ...         | Unit      | ...            | ...            | No        |

_Every AC from prd.md must have ≥1 row in this table. Mark "Yes" if already covered by existing tests._

## 3. Unit Tests
[For each unit test case: file to create, function/class to test, inputs, expected outputs, edge cases to cover]
[Note: Only list new test cases not already covered by existing tests]

## 4. Integration Tests
[For each integration test case: components under test, setup/teardown, steps, expected state after]
[Note: Only list new test cases not already covered by existing tests]

## 5. End-to-End Tests
[For each E2E test case: user journey tested, preconditions, steps, expected UI/system state]
[Note: Only list new test cases not already covered by existing tests]

## 6. Edge Cases & Negative Tests
[Error scenarios, boundary conditions, permission checks, missing inputs]

## 7. Pass/Fail Criteria
- All unit tests pass: **required**
- All integration tests pass: **required**
- All E2E tests pass: **required**
- Code coverage ≥ [X]%: [target from project-context or 80% default]
- No HIGH/MEDIUM security issues found in code review
