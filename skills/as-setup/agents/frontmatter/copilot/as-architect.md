---
name: as-architect
description: auto-scrum architect scan subagent — read-only codebase analysis returning a findings digest
tools: ['read', 'search']
# No model:/effort: here by design. Copilot CLI downgrades a subagent's model to
# the session model under its cost guard, and has no per-agent effort field.
# Set both for the whole run instead: copilot --model <name> --reasoning-effort high
---
