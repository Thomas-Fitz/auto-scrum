---
name: as-dev
description: auto-scrum dev subagent — implements one story or quick-dev change per its dispatched prompt
# No model:/effort: here by design. Copilot CLI downgrades a subagent's model to
# the session model under its cost guard, and has no per-agent effort field.
# Set both for the whole run instead: copilot --model <name> --reasoning-effort high
---
