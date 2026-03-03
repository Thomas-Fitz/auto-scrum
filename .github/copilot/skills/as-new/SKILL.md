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
  Then read `{SKILLS_DIR}/as-new/templates/config-template.yml` and create `.auto-scrum/config.yml` using that content.
Set `SKILLS_DIR`:
- If `auto_scrum.install_mode` is `global`: `SKILLS_DIR = {auto_scrum.global_skills_dir}` (default: `~/.copilot/skills`)
- Otherwise (project or unset): `SKILLS_DIR = .github/copilot/skills`

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


