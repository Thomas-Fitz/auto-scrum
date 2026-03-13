# auto-scrum

Auto-Scrum turns a complex code change into a structured development plan your AI agents can actually handle. Humans drive all planning decisions. AI agents handle autonomous execution.

If [BMAD](https://github.com/bmad-code-org/BMAD-METHOD) is lawful and [GasTown](https://github.com/steveyegge/gastown) is chaotic, Auto-Scrum aims to be neutral.

## Pillars

* **Human in the Loop**: Humans are good at ideas, agents are bad at assumptions. Keep humans in the loop for all planning and decision-making.
* **Test Driven**: Never take an action without a way to measure its result.
* **Adaptable**: Plans change. The auto-scrum team should adjust after each task based on new information.
* **Plug-and-Play**: Auto-Scrum should slot into other parts of your existing software development workflow with minimal friction.

## Prerequisites

* **GitHub Copilot** or **Claude Code**
* **Git** (the project must be a git repository)

## Installation

Copy the skill files into your global skills directory.

```bash
# copilot
cp -r skills/as-* ~/.copilot/skills/

# claude
cp -r skills/as-* ~/.claude/skills/
```

Invoke them by asking Copilot CLI to use a skill by name (e.g. *"use the as-new skill"*) or via `/as-new`. You may need to restart your terminal or Copilot CLI for them to show up.

Then customize `.auto-scrum/config.yml` for your project (created after your first /as-new command):

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
as-quick-dev                               → requirements → architecture → implement → review

```

## Configuration

Edit `.auto-scrum/config.yml`:

```yaml
project:
  name: my-project          # Display name for reports and artifacts
  user: developer           # Developer or team name

artifacts:
  base_dir: .auto-scrum     # Root directory for all auto-scrum artifacts

agents:
  orchestrator:
    model: claude-sonnet-4-6  # Model for pipeline orchestrator
  architect:
    model: claude-sonnet-4-6  # Model for architect agent
  developer:
    model: claude-sonnet-4-6  # Model for developer agent
  reviewer:
    model: claude-sonnet-4-6  # Model for adversarial code reviewer

git:
  commit_frequency: never   # task | story | epic | never

auto_scrum:
  platform: copilot             # 'copilot' | 'claude'
  skills_dir: ~/.copilot/skills # Set automatically by as-new; update if you move your skills
```

## Skills

| Skill | Agent | Human Involvement | Output |
| --------- | ------- | ------------------ | -------- |
| `/as-quick-dev` [beta] | Senior Developer | Medium (Q&A + approach approval) | No artifacts — direct implementation via dev + reviewer agents |
| `/as-new <feature-name>` | — | None | Feature directory scaffold |
| `/as-generate-project-context` [beta] | — | Low (review output) | `project-context.md` |
| `/as-document-project` [beta] | — | Low (review output) | Architecture + source tree docs |
| `/as-prd` | Product Manager | High (Q&A + approval) | `prd.md` |
| `/as-ux-design` [beta] | UX Designer | High (Q&A + approval) | `ux-design.md` |
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
5. **Correct Course:** After each story, evaluates for plan deviations and handles them autonomously.
6. **Epic Retro:** After each epic, synthesizes learnings for the next epic.
7. **Max review cycles:** After 3 failed review cycles, orchestrator makes a judgment call and continues.
8. **Escalates to human only for:** missing required artifact OR unresolvable git conflict.

## Artifact Directory Structure

```text
.auto-scrum/
  config.yml
  features/
    {feature-name}/
      planning/
        prd.md
        ux-design.md          (optional)
        architecture-design.md
        test-plan.md
        epic-breakdown.md
      implementation/
        sprint-status.yaml
        pipeline-report.md
        learning-log.md
        stories/
          {story-key}.md
        checkpoints/
          checkpoint-epic-{N}.md
        retros/
          epic-{N}-retro-{YYYY-MM-DD}.md
  cross-feature/
    project-context.md
    architecture.md
    source-tree.md
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
```

## Credits

* This project is heavily inspired by the work done for [BMAD method](https://github.com/bmad-code-org/BMAD-METHOD)
