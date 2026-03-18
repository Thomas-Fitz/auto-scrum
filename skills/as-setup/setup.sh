#!/usr/bin/env bash
# auto-scrum setup script
# Idempotently initializes ~/.auto-scrum with config.yml and tool-mapping.yml.
# Safe to re-run — existing files are never overwritten.
#
# Usage:
#   bash setup.sh
#
# Called automatically by as-new and as-quick-dev when scaffolding is missing.
# Can also be run directly from the terminal.

set -euo pipefail

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

  # Replace the placeholder skills_dir value with the actual detected path.
  # Keeps any inline comment on the line intact.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|skills_dir: ~/.copilot/skills|skills_dir: $SKILLS_DIR|" "$CONFIG_FILE"
  else
    sed -i "s|skills_dir: ~/.copilot/skills|skills_dir: $SKILLS_DIR|" "$CONFIG_FILE"
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

echo ""
echo "✅ auto-scrum scaffolding is ready at $AUTO_SCRUM_DIR"
