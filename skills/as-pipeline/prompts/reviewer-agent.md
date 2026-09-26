Your agent profile carries your persona, the ABSOLUTE no-revert/no-delete rule, the review dimensions, and the severity rules — they all apply in full. The review protocol below is additional and mandatory for this dispatch.

Story file: {IMPL}/stories/{story-key}.md
Sprint status: {IMPL}/sprint-status.yaml

REQUIRED STEPS — execute all of them:
1. Read the story file first. If no "## Review Cycle N Findings" sections exist yet (this is cycle 1): read EVERY file listed in the File List section. If prior cycle findings exist (cycle 2+): read ONLY files from the File List that were modified during the previous fix round (use `git diff` or file timestamps); do NOT re-report issues already marked fixed in previous cycle findings.
2. For each Acceptance Criterion in the story, determine: IMPLEMENTED / PARTIAL / MISSING.
3. Find ALL real issues across your profile's review dimensions, and classify each by its severity rules.
4. Fast-path: if ALL ACs are IMPLEMENTED and ALL classified issues are LOW severity — skip steps 5 and 6. Go directly to step 7, document all LOW findings with "no fix needed", then apply rule 8a (APPROVED). LOW issues alone are never grounds for rejection. (The fast-path may only be reached by an HONEST grading — re-read your profile's severity rules before taking it.)
5. Run tests ONLY for files/functionality that changed to verify fixes and validate Acceptance Criteria.
6. FIX ALL HIGH and MEDIUM issues directly in the source files.
7. Append your findings to the story file under: ## Review Cycle {review_cycles} Findings
   Format: list each issue with classification, description, and fix applied (or "no fix needed" for LOW).
7b. **Surface out-of-scope follow-ups.** Your fixes (step 6) stay inside this story's scope. When you notice a fixable problem OUTSIDE this story's scope — user-only work, reusable infra another feature should own, a stale/incorrect planning-doc reference, dead/orphaned code, a duplicated test helper, a producer-only contract literal lacking a consumer — APPEND it to the story's `### Surfaced Follow-ups` block (do NOT overwrite the dev agent's entries) using that block's entry shape with a proposed disposition (`interleave` / `cleanup-epic` / `ledger:<key>`). This is distinct from a LOW finding: a LOW is in-scope polish you may leave; a surfaced follow-up is out-of-scope work the orchestrator will route. Do not bury out-of-scope work as a LOW finding — surface it so it gets done or tracked.
8a. If ALL ACs are IMPLEMENTED and no unfixed HIGH/MEDIUM issues remain:
    - **Approval gate — re-confirm BEFORE writing APPROVED:** (a) every AC is IMPLEMENTED (none PARTIAL/MISSING — a flag-set-but-never-read AC is PARTIAL), and (b) zero open in-scope HIGH/MEDIUM findings remain (a MEDIUM may leave this story ONLY if it was genuinely out-of-scope and is now recorded in `### Surfaced Follow-ups`, never as an unfixed in-scope finding). If either fails, you may NOT approve — go to 8b.
    - Update story status to 'done' in the story file (Status: line) AND in {IMPL}/sprint-status.yaml.
    - Write "APPROVED" at the top of the findings section.
8b. If any AC is PARTIAL/MISSING OR any in-scope HIGH/MEDIUM issue is unfixed:
    - A PARTIAL AC is REJECT **even when its only gap is an EXTERNAL dependency** (a missing accessor/hook/asset another feature or the user owns): do NOT mark it done-with-an-asterisk. Surface the dependency in `### Surfaced Follow-ups` as `ledger:cross_feature_handoffs` (or `ledger:blocked_user_actions`) and REJECT — the orchestrator will descope or explicitly defer the AC. NEVER silently mark the story done with an AC still partial.
    - Update story status to 'in-progress' in both files.
    - Write "REJECTED — {list specific blockers}" at the top of the findings section.

If a fix would require deleting or reverting a file, follow your profile's halt rule: do not touch the file, document the finding as HIGH with "Requires USER authorization to delete/revert — halted", set story status to `in-progress` with REJECTED, and return to the orchestrator.

Architecture reference: [include relevant excerpts from {PLAN}/architecture-design.md]
