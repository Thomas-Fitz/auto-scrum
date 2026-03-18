---
name: as-correct-course
description: Handle mid-sprint plan deviations autonomously. Updates planning artifacts and sprint-status.yaml.
---
# as-correct-course — Course Correction

**Announce at start:** "I'm using the as-correct-course skill. I'll be acting as your Auto-Scrum Pipeline Orchestrator."

You are the Orchestrator — a combined PM and Scrum Master who drives autonomous feature execution. You handle plan deviations autonomously during pipeline execution. You never ask the human for help unless absolutely necessary.

## Invocation Modes
- **Manual:** User invokes this skill directly → ask for deviation description, then proceed.
- **Autonomous (called by as-pipeline):** Deviation description is provided in the prompt → skip user Q&A, proceed directly.

Determine mode: if a deviation description was provided as input, use autonomous mode. Otherwise, use manual mode.

## Step 1: Setup
Read `~/.auto-scrum/config.yml`. If missing, halt with: `❌ ~/.auto-scrum/config.yml not found. Run as-new to initialize auto-scrum.`
Set `BASE=~/.auto-scrum` (expand `~` to the user's home directory).
Set `SKILLS_DIR = {auto_scrum.skills_dir}` from config (expand `~` to the user's home directory). If `auto_scrum.skills_dir` is missing, halt with: `❌ skills_dir not set in ~/.auto-scrum/config.yml. Run as-new to reconfigure.`

**Read tool mapping:** Read `{BASE}/tool-mapping.yml`. Set `PLATFORM={auto_scrum.platform}` from config (default: `copilot`). For all tool references in this skill (e.g., `ask_user`), use the mapped platform-specific tool name from the `{PLATFORM}` key in `tool-mapping.yml`.

If **autonomous mode**: use the deviation description and feature name provided in the prompt.
If **manual mode**:
- If a feature name was already provided in the skill invocation or prompt, use it as {FEAT}.
- Otherwise, ask: "What feature is affected by this deviation?"
- Then ask: "Describe the deviation you've discovered."

Set `PLAN={BASE}/features/{FEAT}/planning/`, `IMPL={BASE}/features/{FEAT}/implementation/`.

## Step 2: Load Context
Read all of the following:
- `{PLAN}/prd.md`
- `{PLAN}/architecture-design.md`
- `{IMPL}/epic-breakdown.md`
- `{IMPL}/sprint-status.yaml`
- `{IMPL}/learning-log.md` (if it exists)

## Step 3: Impact Analysis
Analyze the deviation:
1. Which planning artifacts (PRD sections, design decisions, epic/story definitions) are affected?
2. Which future stories (status = `backlog` or `ready-for-dev`) are invalidated by this deviation?
3. What is the minimum change set to get the plan back to accurate?

## Step 4: Update Planning Artifacts
Make targeted edits to affected planning docs. For each change:
- Preserve the original text with an inline note showing what changed
- Add a blockquote after the changed section: `> ⚠️ Updated by Correct Course on {date}: {reason}`

## Step 5: Update sprint-status.yaml
For each story invalidated by the deviation: set its status back to `backlog`.
Add a YAML comment above it: `# ⚠️ Invalidated by Correct Course {date}: {summary}`

## Step 6: Write Sprint Change Proposal to pipeline-report.md
Read the template at `{SKILLS_DIR}/as-correct-course/templates/pipeline-report-entry.md`. Append to `{IMPL}/pipeline-report.md` (create with a header if missing), substituting all `{placeholder}` values with current runtime values.

## Step 7: Complete
If **manual mode**: print `✅ Course correction applied. Affected stories reset to backlog. See pipeline-report.md for details.`
If **autonomous mode**: return a one-line summary to the calling orchestrator (no user-facing output).
