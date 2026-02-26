---
name: as-new
description: Scaffold a new auto-scrum feature artifact directory under .auto-scrum/features/{feature-name}/
---
# as-new — New Feature Scaffold

**Announce at start:** "I'm using the as-new skill to scaffold the feature directory."

You are initializing a new auto-scrum feature. Ask the user for the feature name if not already provided (e.g., `user-authentication`).

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
Create the following directories:
- `{BASE}/features/{FEAT}/planning/`
- `{BASE}/features/{FEAT}/implementation/`
- `{BASE}/features/{FEAT}/implementation/stories/`
- `{BASE}/features/{FEAT}/implementation/checkpoints/`
- `{BASE}/features/{FEAT}/implementation/retros/`

## Step 4: Print summary
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
Print: `Next step: run the as-prd skill to create the Product Requirements Document.`

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
    model: claude-sonnet-4-5  # Model ID for the pipeline orchestrator
  architect:
    model: claude-sonnet-4-5  # Model ID for the architect agent
  developer:
    model: claude-sonnet-4-5  # Model ID for the developer agent
  reviewer:
    model: claude-sonnet-4-5  # Model ID for the adversarial code reviewer

git:
  # task | story | epic | never (default: never)
  commit_frequency: never
```
