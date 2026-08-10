#!/usr/bin/env bash
# auto-scrum setup script
# Idempotently initializes ~/.auto-scrum with config.yml and tool-mapping.yml.
# Safe to re-run — existing files are never overwritten.
#
# Usage:
#   bash setup.sh
#   bash setup.sh --sync-agents --force   # re-render agent profiles, overwriting local edits
#
# Called automatically by as-new and as-quick-dev when scaffolding is missing.
# Can also be run directly from the terminal.

set -euo pipefail

SYNC_AGENTS=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --sync-agents) SYNC_AGENTS=true ;;
    --force) FORCE=true ;;
    -h|--help)
      echo "Usage: bash setup.sh [--sync-agents] [--force]"
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $arg"
      echo "   Usage: bash setup.sh [--sync-agents] [--force]"
      exit 1
      ;;
  esac
done

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SKILLS_DIR=$(dirname "$SCRIPT_DIR")
AUTO_SCRUM_DIR="$HOME/.auto-scrum"

CONFIG_TEMPLATE="$SKILLS_DIR/as-new/templates/config-template.yml"
TOOL_MAPPING_TEMPLATE="$SKILLS_DIR/as-new/templates/tool-mapping-template.yml"

# --- Validate templates ---

if [[ ! -f "$CONFIG_TEMPLATE" ]]; then
  echo "❌ Config template not found at: $CONFIG_TEMPLATE"
  echo "   Ensure as-new is installed in the same skills directory as as-setup."
  exit 1
fi

if [[ ! -f "$TOOL_MAPPING_TEMPLATE" ]]; then
  echo "❌ Tool mapping template not found at: $TOOL_MAPPING_TEMPLATE"
  echo "   Ensure as-new is installed in the same skills directory as as-setup."
  exit 1
fi

# --- Create ~/.auto-scrum directory structure ---

created_dirs=()

for dir in "$AUTO_SCRUM_DIR" "$AUTO_SCRUM_DIR/features" "$AUTO_SCRUM_DIR/cross-feature"; do
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    created_dirs+=("$dir")
  fi
done

if [[ ${#created_dirs[@]} -gt 0 ]]; then
  echo "✅ Created directory: $AUTO_SCRUM_DIR"
fi

# --- Create config.yml ---

CONFIG_FILE="$AUTO_SCRUM_DIR/config.yml"

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

  # Replace the placeholder skills_dir and platform values with the actual detected path.
  # Keeps any inline comment on the line intact.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|skills_dir: [^ #]*|skills_dir: $SKILLS_DIR|" "$CONFIG_FILE"
  else
    sed -i "s|skills_dir: [^ #]*|skills_dir: $SKILLS_DIR|" "$CONFIG_FILE"
  fi

  # Auto-detect platform from install location
  if [[ "$SKILLS_DIR" == "$HOME/.config/opencode/"* ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|platform: [^ #]*|platform: opencode|" "$CONFIG_FILE"
    else
      sed -i "s|platform: [^ #]*|platform: opencode|" "$CONFIG_FILE"
    fi
  fi

  echo "✅ Created $CONFIG_FILE"
  echo "   skills_dir set to: $SKILLS_DIR"
  echo "   Customize this file at any time."
else
  echo "⚠️  $CONFIG_FILE already exists — skipped."
fi

# --- Create tool-mapping.yml ---

TOOL_MAPPING_FILE="$AUTO_SCRUM_DIR/tool-mapping.yml"

if [[ ! -f "$TOOL_MAPPING_FILE" ]]; then
  cp "$TOOL_MAPPING_TEMPLATE" "$TOOL_MAPPING_FILE"
  echo "✅ Created $TOOL_MAPPING_FILE"
else
  echo "⚠️  $TOOL_MAPPING_FILE already exists — skipped."
fi

# --- Create OpenCode commands (if applicable) ---

if [[ "$SKILLS_DIR" == "$HOME/.config/opencode/"* ]]; then
  OPENCODE_COMMANDS_SRC="$SCRIPT_DIR/opencode-commands"
  OPENCODE_COMMANDS_DIR="$HOME/.config/opencode/commands"

  if [[ -d "$OPENCODE_COMMANDS_SRC" ]]; then
    mkdir -p "$OPENCODE_COMMANDS_DIR"
    copied=0
    for cmd_file in "$OPENCODE_COMMANDS_SRC"/*.md; do
      dest="$OPENCODE_COMMANDS_DIR/$(basename "$cmd_file")"
      if [[ ! -f "$dest" ]]; then
        cp "$cmd_file" "$dest"
        copied=$((copied + 1))
      fi
    done
    if [[ $copied -gt 0 ]]; then
      echo "✅ Created $copied OpenCode command(s) in $OPENCODE_COMMANDS_DIR"
    else
      echo "⚠️  OpenCode commands already exist — skipped."
    fi
  fi
fi

# --- Install agent profiles ---
#
# Each profile is a per-platform frontmatter fragment concatenated with the shared
# role body, so a role's persona and rules exist in exactly one place.

AGENTS_SRC="$SCRIPT_DIR/agents"
ROLES=(as-dev as-reviewer as-generic as-architect as-qa)

if [[ "$SKILLS_DIR" == "$HOME/.config/opencode/"* ]]; then
  AGENT_PLATFORM="opencode"
elif [[ "$SKILLS_DIR" == "$HOME/.copilot/"* ]]; then
  AGENT_PLATFORM="copilot"
elif [[ "$SKILLS_DIR" == "$HOME/.claude/"* ]]; then
  AGENT_PLATFORM="claude"
elif [[ -d "$HOME/.claude" ]]; then
  AGENT_PLATFORM="claude"
else
  AGENT_PLATFORM="copilot"
fi

case "$AGENT_PLATFORM" in
  opencode)
    # Docs name this directory `agents`, while the JSON config key is singular.
    # Honour whichever already exists rather than hardcoding one.
    if [[ -d "$HOME/.config/opencode/agent" && ! -d "$HOME/.config/opencode/agents" ]]; then
      AGENTS_DIR="$HOME/.config/opencode/agent"
    else
      AGENTS_DIR="$HOME/.config/opencode/agents"
    fi
    AGENT_EXT=".md"
    ;;
  copilot)
    AGENTS_DIR="$HOME/.copilot/agents"
    AGENT_EXT=".agent.md"
    ;;
  claude)
    AGENTS_DIR="$HOME/.claude/agents"
    AGENT_EXT=".md"
    ;;
esac

if [[ ! -d "$AGENTS_SRC" ]]; then
  echo "⚠️  Agent profile sources not found at $AGENTS_SRC — skipped profile install."
else
  mkdir -p "$AGENTS_DIR"

  if [[ "$SYNC_AGENTS" == true && "$FORCE" != true ]]; then
    echo "❌ --sync-agents re-renders every profile from the repo and DISCARDS local edits."
    echo "   Re-run with --force if that is what you want:"
    echo "   bash setup.sh --sync-agents --force"
    exit 1
  fi

  installed=0
  synced=0
  skipped=0

  for role in "${ROLES[@]}"; do
    frontmatter="$AGENTS_SRC/frontmatter/$AGENT_PLATFORM/$role.md"
    body="$AGENTS_SRC/roles/$role.md"
    dest="$AGENTS_DIR/$role$AGENT_EXT"

    if [[ ! -f "$frontmatter" || ! -f "$body" ]]; then
      echo "⚠️  Missing source for $role — skipped."
      continue
    fi

    if [[ -f "$dest" && "$SYNC_AGENTS" != true ]]; then
      skipped=$((skipped + 1))
      continue
    fi

    existed=false
    if [[ -f "$dest" ]]; then
      existed=true
    fi

    cat "$frontmatter" "$body" > "$dest"

    if [[ "$existed" == true ]]; then
      synced=$((synced + 1))
    else
      installed=$((installed + 1))
    fi
  done

  echo "✅ Agent profiles ($AGENT_PLATFORM): $AGENTS_DIR"
  if [[ $installed -gt 0 ]]; then
    echo "   Installed $installed profile(s)."
  fi
  if [[ $synced -gt 0 ]]; then
    echo "   Re-rendered $synced existing profile(s) (local edits discarded)."
  fi
  if [[ $skipped -gt 0 ]]; then
    echo "   Skipped $skipped existing profile(s) — run with --sync-agents --force to re-render."
  fi

  if [[ "$AGENT_PLATFORM" == "copilot" ]]; then
    echo "   Copilot CLI has no per-agent model or reasoning-effort setting — set them for"
    echo "   the whole session instead: copilot --model <name> --reasoning-effort high"
  fi
fi

echo ""
echo "✅ auto-scrum scaffolding is ready at $AUTO_SCRUM_DIR"
