---
name: as-new
description: Scaffold a new auto-scrum feature artifact directory under ~/.auto-scrum/features/{feature-name}/
---
# as-new — New Feature Scaffold

**Announce at start:** "I'm using the as-new skill to scaffold the feature directory."

You are initializing a new auto-scrum feature. If a feature name was already provided in the skill invocation, use it as `FEAT`. Otherwise, ask the user for the feature name (e.g., `user-authentication`).

## Step 1: Read Configuration

Remember the feature name as {FEAT} going forward in this session. Retain this through any compaction or summarization steps, unless the user explicitly changes it.

**Resolve SKILLS_DIR**:
- If `~/.auto-scrum/config.yml` exists:
  - Read it and set `SKILLS_DIR = {auto_scrum.skills_dir}` (expand `~` to the user's home directory).
  - If `auto_scrum.skills_dir` is missing, halt with: `❌ skills_dir not set in ~/.auto-scrum/config.yml. Re-run as-new to reconfigure.`
- If `~/.auto-scrum/config.yml` does not exist:
  1. Probe candidate skill directories in this order (expand `~` in all paths):
     - `~/.copilot/skills`
     - `~/.claude/skills`
     - `.github/copilot/skills`
     - `.claude/skills`
  2. Set `SKILLS_DIR` to the first directory that contains `as-new/templates/config-template.yml`.
  3. If no candidate contains that template, halt with:
     `❌ Could not find as-new config template. Checked: ~/.copilot/skills, ~/.claude/skills, .github/copilot/skills, .claude/skills`

**Read or create global config:**
- If `~/.auto-scrum/config.yml` **exists**: read it.
- If `~/.auto-scrum/config.yml` **does not exist**:
  1. Print: `⚠️  ~/.auto-scrum/config.yml not found. Creating from your base config.`
  2. Read `{SKILLS_DIR}/as-new/templates/config-template.yml` as the base.
  3. Create the `~/.auto-scrum/` directory if it does not exist.
  4. Write `~/.auto-scrum/config.yml` with all settings from the base config, then override:
     - `project.name` → `{FEAT}` (set to the feature/project name)
     - `auto_scrum.skills_dir` → `{SKILLS_DIR}` (the directory found by probing above)
  5. Print: `✅ Created ~/.auto-scrum/config.yml with base settings. You can customize this at any time.`

Set `BASE=~/.auto-scrum` (expand `~` to the user's home directory).

**Read or create tool mapping:**
- If `{BASE}/tool-mapping.yml` **exists**: read it.
- If `{BASE}/tool-mapping.yml` **does not exist**:
  1. Read `{SKILLS_DIR}/as-new/templates/tool-mapping-template.yml`.
  2. Write `{BASE}/tool-mapping.yml` with the contents of the template.

Set `PLATFORM={auto_scrum.platform}` from config (default: `copilot`).
Resolve tool names: for all tool references in this and subsequent skills, look up the generic tool name under the `{PLATFORM}` key in `tool-mapping.yml` and use the mapped platform-specific tool name.

## Step 2: Idempotency Check
Check if `{BASE}/features/{FEAT}/` already exists.
- If it does: print `⚠️  Feature directory already exists at {BASE}/features/{FEAT}/. No files were overwritten.` and stop.
- If it does not: continue.

## Step 3: Create Directory Structure
Create the following directories:
- `{BASE}/cross-feature/`
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

**Use the `ask_user` tool for next workflow step:**
Ask: "Would you like to automatically start the as-prd skill now to create the Product Requirements Document, or continue in another session?"
Offer options: "Start as-prd now", "Continue later"
If user selects "Start as-prd now": execute `/as-prd {FEAT}` (substitute the actual feature name)

