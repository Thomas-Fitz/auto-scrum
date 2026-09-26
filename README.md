# auto-scrum

Auto-Scrum turns a complex code change into a structured development plan your AI agents can actually handle. Humans drive all planning decisions. AI agents handle autonomous execution.

If [BMAD](https://github.com/bmad-code-org/BMAD-METHOD) is lawful and [GasTown](https://github.com/steveyegge/gastown) is chaotic, Auto-Scrum aims to be neutral.

## Pillars

* **Human in the Loop**: Humans are good at ideas, agents are bad at assumptions. Keep humans in the loop for all planning and decision-making.
* **Test Driven**: Never take an action without a way to measure its result.
* **Adaptable**: Plans change. The auto-scrum team should adjust after each task based on new information.
* **Plug-and-Play**: Auto-Scrum should slot into other parts of your existing software development workflow with minimal friction.

## Prerequisites

* **GitHub Copilot**, **Claude Code**, or **[OpenCode](https://opencode.ai)**
* **Git** (the project must be a git repository)

## Installation

Copy the skill files into your global skills directory.

```bash
# copilot
cp -r skills/as-* ~/.copilot/skills/

# claude
cp -r skills/as-* ~/.claude/skills/

# opencode
cp -r skills/as-* ~/.config/opencode/skills/
```

The `~/.auto-scrum/` directory, the config files, and the [agent profiles](#agent-profiles) are created automatically the first time you run `/as-new` or `/as-quick-dev`. You can also run the setup script directly at any time:

```bash
# copilot
bash ~/.copilot/skills/as-setup/setup.sh

# claude
bash ~/.claude/skills/as-setup/setup.sh

# opencode (also installs /as-* slash commands)
bash ~/.config/opencode/skills/as-setup/setup.sh
```

Setup prints the directory it installed the agent profiles into. Existing profiles are never overwritten — after upgrading auto-scrum, re-render them with `bash <skills_dir>/as-setup/setup.sh --sync-agents --force`.

> **Upgrading from a version before agent profiles?** Sub-agents are now dispatched by type (`as-dev`, `as-reviewer`, …) instead of being configured in `config.yml`. Run the setup script once to install the profiles, and delete the now-unused `agents:` block from `~/.auto-scrum/config.yml`.

Invoke skills via `/as-new` in Copilot CLI, Claude Code, or OpenCode. You can also say *"use the as-new skill"* and the agent will load it automatically. You may need to restart your terminal for skills to show up.

Then customize `~/.auto-scrum/config.yml` for your setup (created automatically the first time you run `/as-new` or `/as-quick-dev`):

```yaml
# Workflow Order
as-new <feature-name>                      → scaffold artifact directory
as-prd <feature-name>                      → write Product Requirements Document
as-ux-design <feature-name>                → optional: UX design doc for UI-heavy features
as-architect <feature-name>                → write Architecture Design Document
as-test-plan <feature-name>                → write Test Plan
as-sprint-plan <feature-name>              → produce Epic Breakdown + Sprint Status
as-pipeline <feature-name>                 → 🚀 autonomous execution begins

# Quick Workflow - Small Changes (beta):
as-quick-dev                               → complexity gate → context scan → requirements → architecture → test plan → implement → review

```

## Configuration

Edit `~/.auto-scrum/config.yml`:

```yaml
project:
  name: my-project          # Display name for reports and artifacts
  user: developer           # Developer or team name

git:
  commit_frequency: never   # task | story | epic | never

auto_scrum:
  platform: copilot             # 'copilot' | 'claude' | 'opencode'
  skills_dir: ~/.copilot/skills # Set automatically by setup; update if you move your skills
```

Sub-agent models and reasoning effort are **not** set here — they live in the agent profiles below. The orchestrator runs on your session model, chosen in your harness (`/model`).

## Agent Profiles

Every sub-agent role has a profile installed by `as-setup`. The profile body carries that role's persona, the no-revert/no-delete safety rule, and its standards; the frontmatter pins its model and reasoning effort where the harness supports it. Skills dispatch by `subagent_type` and never pass a `model:` parameter — a per-dispatch model would silently override the profile.

| Profile | Role | Dispatched by |
| --- | --- | --- |
| `as-dev` | Implements one story or quick-dev change | `/as-pipeline`, `/as-quick-dev` |
| `as-reviewer` | Adversarial code review, fixes what it finds | `/as-pipeline`, `/as-quick-dev` |
| `as-generic` | Retro, doc reconciliation, follow-ups rendering | `/as-pipeline` |
| `as-architect` | Read-only codebase scan for planning docs | `/as-prd`, `/as-ux-design`, `/as-architecture-design`, `/as-quick-dev` |
| `as-qa` | Read-only test-landscape scan | `/as-test-plan` |

To retune a role, edit its installed profile — not `config.yml`. Source lives in `skills/as-setup/agents/`: one shared body per role in `roles/`, plus a per-platform frontmatter fragment in `frontmatter/<platform>/`, which setup concatenates.

Harness capabilities differ, so the frontmatter does too:

| | Claude Code | OpenCode | Copilot CLI |
| --- | --- | --- | --- |
| profile directory | `~/.claude/agents/` | `~/.config/opencode/agents/` | `~/.copilot/agents/` |
| file extension | `.md` | `.md` | `.agent.md` |
| per-role model | ✅ `model:` | ✅ `model:` (provider-qualified) | ❌ downgraded to the session model |
| per-role effort | ✅ `effort:` | ❌ markdown has no field | ❌ session-global only |
| typed dispatch | ✅ `subagent_type` | ✅ `subagent_type` / `@name` | by name / inference |

On Copilot CLI, set the compute for the whole run instead: `copilot --model <name> --reasoning-effort high`. OpenCode profiles ship without a `model:` line so they inherit your session model — uncomment and set a provider-qualified id (e.g. `anthropic/claude-opus-4-5`) to pin one.

## Skills

| Skill | Agent | Human Involvement | Output |
| --------- | ------- | ------------------ | -------- |
| `/as-quick-dev` [beta] | Senior Developer | Medium (Q&A + approach approval) | No artifacts — direct implementation via dev + reviewer agents |
| `/as-new <feature-name>` | — | None | Feature directory scaffold |
| `/as-prd` | Product Manager | High (Q&A + approval) | `prd.md` |
| `/as-ux-design` [beta] | UX Designer | High (Q&A + approval) | `ux-design.md` (+ optional HTML/CSS/JS prototype) |
| `/as-architecture-design` | Architect | High (Q&A + approval) | `architecture-design.md` |
| `/as-test-plan` | QA | Medium (review + approval) | `test-plan.md` |
| `/as-sprint-plan` | Scrum Master | Medium (review + approval) | `epic-breakdown.md`, `sprint-status.yaml` |
| `/as-pipeline <feature-name>` | Orchestrator | None (unless hard blocker) | All implementation artifacts |
| `/as-correct-course` | Orchestrator | None (auto-triggered) or Low (manual) | Sprint Change Proposal in `pipeline-report.md` |
| `/as-tech-writer` [beta] | Tech Writer | Medium (describe ask) | Docs, diagrams |

## Pipeline Behavior

The `/as-pipeline` skill:

1. **Readiness Check:** Validates required artifacts exist before starting.
2. **Resume:** Detects `in-progress` or `review` stories and resumes from them.
3. **Per-epic:** Writes a checkpoint file, compacts context, then processes each story.
4. **Per-story:** Orchestrator writes the story → dev agent implements (TDD) → adversarial reviewer finds + fixes issues → learning log updated.
5. **Follow-up triage:** After each story, out-of-scope items the dev/reviewer surfaced are routed to exactly one of: interleave now, a cleanup epic (drained before the feature closes), or the follow-ups ledger (work only a user/another feature can do).
6. **Correct Course:** After each story, evaluates for plan deviations and handles them autonomously.
7. **Epic Retro + Doc Reconciliation:** After each epic, synthesizes learnings and dispositions follow-ups, then flushes recorded deltas back into the living planning docs so the next epic starts accurate.
8. **Feature-completion gate:** Sweeps the learning log for guidance nothing consumed, verifies every story/epic (including the cleanup epic) is `done`, then delivers `followups.md` — every ledger item listed individually with verified counts, plus conventions and carry-forward guidance from the last retro.
9. **Max review cycles:** After 3 failed review cycles, orchestrator makes a judgment call and continues.
10. **Safety:** No agent may revert or delete files without explicit user authorization — a hard stop.
11. **Escalates to human only for:** missing required artifact, an unresolvable git conflict, or a destructive operation needing authorization.

## Artifact Directory Structure

```text
~/.auto-scrum/
  config.yml
  features/
    {feature-name}/           ← not tied to any single repo; can span multiple
      planning/
        prd.md
        ux-design.md          (optional)
        architecture-design.md
        test-plan.md
        epic-breakdown.md
      prototypes/             (optional, from as-ux-design)
        *.html, style.css
      implementation/
        sprint-status.yaml
        pipeline-report.md
        learning-log.md
        followups.md          ← delivered at feature completion: open items only a user/another feature can do
        stories/
          {story-key}.md      ← includes Repo: field declaring which directory to work in
        checkpoints/
          checkpoint-epic-{N}.md
        retros/
          epic-{N}-retro-{YYYY-MM-DD}.md
  cross-feature/
```

## Sprint Status Schema

```yaml
generated: YYYY-MM-DD HH:MM
project: string
feature: string
artifacts_dir: string

development_status:
  epic-1: backlog           # backlog | in-progress | done
  1-1-story-title: backlog  # backlog | ready-for-dev | in-progress | review | done
  1-2-story-title: backlog
  epic-1-retrospective: optional  # optional | done
  epic-2: backlog
  2-1-story-title: backlog
  epic-2-retrospective: optional
```

## Story File Template

```markdown
# Story {epic_num}.{story_num}: {story_title}

Status: ready-for-dev

## Story
As a {role},
I want {action},
so that {benefit}.

## Acceptance Criteria
1. [Specific, testable criterion]

## Tasks / Subtasks
- [ ] Task 1 (AC: #1)
  - [ ] Subtask 1.1: Write failing test for [specific behavior]
  - [ ] Subtask 1.2: Implement [specific thing] to make test pass
  - [ ] Subtask 1.3: Refactor

## Dev Notes
**Architecture:** [patterns from architecture-design.md]
**Files to modify:** [exact paths]
**Files to create:** [exact paths]
**Testing approach:** [framework, locations, assertions]
**Edge cases:** [specific cases to handle]
**Integration points:** [what this touches]

### Previous Learnings
[Insights from previous story or epic retro]

### References
- [Source: architecture-design.md#Section]
- [Source: prd.md#FR-N]
- [Source: test-plan.md#AC-N]

## Dev Agent Record
### Agent Model Used
### Completion Notes
### File List
### Plan Deviations
### Destructive Operation Requests
### Surfaced Follow-ups
```

## Credits

* This project is heavily inspired by the work done for [BMAD method](https://github.com/bmad-code-org/BMAD-METHOD)
