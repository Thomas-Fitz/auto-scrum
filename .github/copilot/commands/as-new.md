---
description: Scaffold a new feature's artifact directory structure under .auto-scrum/features/{feature-name}/
allowed-tools: [ReadFile, WriteFile, CreateDirectory, ListDirectory, FindFiles, RunTerminalCommand]
---
# /as-new — New Feature Scaffold

You are initializing a new auto-scrum feature. The feature name is provided as the argument to this command (e.g., `/as-new user-authentication`).

## Step 1: Read Configuration
Attempt to read `.auto-scrum/config.yml`.
- If found: use `artifacts.base_dir` as the base directory.
- If NOT found: use `.auto-scrum` as the default AND print a visible warning:
  `⚠️  WARNING: .auto-scrum/config.yml not found. Using default base directory: .auto-scrum`
  Then create `.auto-scrum/config.yml` with the template content from the Config Template appendix at the bottom of this file.

Set `BASE={artifacts.base_dir}` and `FEAT={feature-name}`.

## Step 2: Idempotency Check
Check if `{BASE}/features/{FEAT}/` already exists.
- If it does: print `⚠️  Feature directory already exists at {BASE}/features/{FEAT}/. No files were overwritten.` and stop.
- If it does not: continue.

## Step 3: Create Directory Structure
Create the following directories (use CreateDirectory for each):
- `{BASE}/features/{FEAT}/planning/`
- `{BASE}/features/{FEAT}/implementation/`
- `{BASE}/features/{FEAT}/implementation/stories/`
- `{BASE}/features/{FEAT}/implementation/checkpoints/`
- `{BASE}/features/{FEAT}/implementation/retros/`

## Step 4: Create placeholder files
Create these files with a one-line placeholder comment:
- `{BASE}/features/{FEAT}/planning/.gitkeep` — content: `# planning artifacts go here`
- `{BASE}/features/{FEAT}/implementation/.gitkeep` — content: `# implementation artifacts go here`

## Step 5: Git tracking
Run: `git add {BASE}/features/{FEAT}/`
If git is not available or not a repo, print a warning but do not halt.

## Step 6: Print summary
Print the created directory tree:
```
✅ Feature '{FEAT}' initialized:
{BASE}/features/{FEAT}/
├── planning/
└── implementation/
    ├── stories/
    ├── checkpoints/
    └── retros/
```
Print: `Next step: run /as-prd to create the Product Requirements Document.`

## Config Template (Appendix)
If config.yml needs to be created, use this content:

```yaml
# auto-scrum configuration
project:
  name: my-project          # Display name for reports and artifacts
  user: developer           # Developer or team name

artifacts:
  base_dir: .auto-scrum     # Root directory for all auto-scrum artifacts

agents:
  orchestrator:
    model: claude-sonnet-4-5  # Model ID for the pipeline orchestrator (Marcus)
  architect:
    model: claude-sonnet-4-5  # Model ID for the architect agent (Winston)
  developer:
    model: claude-sonnet-4-5  # Model ID for the developer agent (Amelia)
  reviewer:
    model: claude-sonnet-4-5  # Model ID for the adversarial code reviewer

git:
  # task | story | epic | never (default: story)
  commit_frequency: story
```
