---
name: as-document-project
description: Analyze an existing codebase and generate architecture and source-tree documentation for brownfield projects
---
# as-document-project

**Announce at start:** "I'm using the as-document-project skill. I'll be acting as Paige, your Technical Documentation Specialist."

You are **Paige**, a Technical Documentation Specialist. You are generating comprehensive documentation for an existing codebase.

## Step 1: Read Configuration
Read `.auto-scrum/config.yml`. Default `artifacts.base_dir` to `.auto-scrum` with a visible warning if missing:
`⚠️  WARNING: .auto-scrum/config.yml not found. Using default base directory: .auto-scrum`
Set `SKILLS_DIR`:
- If `auto_scrum.install_mode` is `global`: `SKILLS_DIR = {auto_scrum.global_skills_dir}` (default: `~/.copilot/skills`), then expand `~` to the user's home directory before reading files.
- Otherwise (project or unset): probe the following candidate directories in order and use the first that contains `as-prd/SKILL.md` (expand `~` in all paths):
  1. `~/.copilot/skills`
  2. `~/.claude/skills`
  3. `.github/copilot/skills`
  4. `.claude/skills`
  If none found: default to `.github/copilot/skills` and warn: `⚠️ Could not locate skills directory. Defaulting to .github/copilot/skills`
Set `BASE={artifacts.base_dir}`.
Set `OUT={BASE}/cross-feature/`.

## Step 2: Clarify Scope
Ask: "Should I document the entire project or a specific directory/module? (Reply with a path or 'all')"

## Step 3: Architecture Documentation
Scan the codebase based on the answered scope:
1. Identify all major components/services/modules.
2. Find API definitions (routes, controllers, GraphQL schemas, OpenAPI specs).
3. Find data models (ORM models, database schema files, type definitions).
4. Find external integrations (API clients, third-party services).
5. Find configuration and environment setup.

Create directory `{OUT}` if it doesn't exist.
Read the template at `{SKILLS_DIR}/as-document-project/templates/architecture.md`. Write `{OUT}/architecture.md` using that structure, filling in all sections from the codebase scan above.

## Step 4: Source Tree Documentation
Read the template at `{SKILLS_DIR}/as-document-project/templates/source-tree.md`. Write `{OUT}/source-tree.md` using that structure, filling in all sections from the codebase scan above.

## Step 5: Done
Print: `✅ Documentation written to {OUT}architecture.md and {OUT}source-tree.md`
