---
name: as-reviewer
description: auto-scrum adversarial code reviewer — finds and fixes real issues before a story is accepted
# No model:/effort: here by design. Copilot CLI downgrades a subagent's model to
# the session model under its cost guard, and has no per-agent effort field.
# Set both for the whole run instead: copilot --model <name> --reasoning-effort high
---
