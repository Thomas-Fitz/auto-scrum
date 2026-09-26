# Agent profiles

Each auto-scrum sub-agent role is defined once here and installed into your harness by
`skills/as-setup/setup.sh`.

```
roles/         one body per role — persona, safety rules, and standards that apply to
               EVERY dispatch of that role. Platform-independent.
frontmatter/   per-platform YAML headers. setup.sh concatenates
               frontmatter/<platform>/<role>.md + roles/<role>.md into one profile file.
```

| Role | Used by |
| ---- | ------- |
| `as-dev` | `/as-pipeline` story implementation, `/as-quick-dev` |
| `as-reviewer` | adversarial review in `/as-pipeline` and `/as-quick-dev` |
| `as-generic` | epic retro, doc reconciliation, follow-ups delivery |
| `as-architect` | read-only codebase scans in `/as-prd`, `/as-ux-design`, `/as-architecture-design` |
| `as-qa` | read-only test-landscape scan in `/as-test-plan` |

The orchestrator has no profile — it runs as your main session, so its model is whatever
you select with `/model` (or `--model`).

## Editing

The installed profile is the source of truth; edit it in place to change a role's model,
reasoning effort, tools, or rules:

| Platform | Installed to |
| -------- | ------------ |
| Claude Code | `~/.claude/agents/as-*.md` |
| OpenCode | `~/.config/opencode/agents/as-*.md` |
| Copilot CLI | `~/.copilot/agents/as-*.agent.md` |

`setup.sh` never overwrites an existing profile. To pull in updated role text after
upgrading auto-scrum, run `setup.sh --sync-agents --force` — this discards local edits to
the profile files.

## Why the frontmatter differs per platform

| | Claude Code | OpenCode | Copilot CLI |
| --- | --- | --- | --- |
| Per-role model | `model:` | `model:` (provider-qualified) | cost guard downgrades it |
| Per-role reasoning effort | `effort:` | not supported in markdown | not supported |

Claude Code profiles pin both. OpenCode profiles leave `model:` unset so the agent inherits
your session model — OpenCode is provider-agnostic, so shipping a hardcoded Anthropic id
would break anyone running a different provider; a commented example shows how to pin one.
Copilot profiles carry persona and rules only: its cost guard downgrades a subagent's model
to the session model, and it has no per-agent effort field, so `--model` and
`--reasoning-effort` at launch are the levers there.
