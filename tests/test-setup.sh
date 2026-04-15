#!/usr/bin/env bash
# Unit tests for skills/as-setup/setup.sh
# Run: bash tests/test-setup.sh
#
# Strategy: override HOME to a temp directory so the real filesystem is never
# touched, build a mock skill tree with symlinks to the real files, then
# exercise setup.sh and assert outcomes.

set -uo pipefail

# ---------------------------------------------------------------------------
# Paths (derived from this script's location — never hardcoded)
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REAL_SETUP="$REPO_ROOT/skills/as-setup/setup.sh"
REAL_COMMANDS_DIR="$REPO_ROOT/skills/as-setup/opencode-commands"
REAL_CONFIG_TEMPLATE="$REPO_ROOT/skills/as-new/templates/config-template.yml"
REAL_TOOL_MAPPING_TEMPLATE="$REPO_ROOT/skills/as-new/templates/tool-mapping-template.yml"

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_TEST=""
ORIG_HOME="$HOME"
TMPDIR_BASE=""

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Helpers — mock builders
# ---------------------------------------------------------------------------

# Creates a copilot-style mock:
#   $TMPDIR/.copilot/skills/  ← SKILLS_DIR
#     as-setup/setup.sh       ← symlink
#     as-setup/opencode-commands/ ← symlink
#     as-new/templates/       ← symlinks to real templates
setup_copilot_mock() {
  TMPDIR_BASE="$(mktemp -d)"
  export HOME="$TMPDIR_BASE"

  local skills="$TMPDIR_BASE/.copilot/skills"
  mkdir -p "$skills/as-setup"
  mkdir -p "$skills/as-new/templates"

  ln -s "$REAL_SETUP"                  "$skills/as-setup/setup.sh"
  ln -s "$REAL_COMMANDS_DIR"           "$skills/as-setup/opencode-commands"
  ln -s "$REAL_CONFIG_TEMPLATE"        "$skills/as-new/templates/config-template.yml"
  ln -s "$REAL_TOOL_MAPPING_TEMPLATE"  "$skills/as-new/templates/tool-mapping-template.yml"

  MOCK_SETUP="$skills/as-setup/setup.sh"
  MOCK_SKILLS_DIR="$skills"
}

# Creates an opencode-style mock:
#   $TMPDIR/.config/opencode/skills/  ← SKILLS_DIR
#     (same internal layout as copilot mock)
setup_opencode_mock() {
  TMPDIR_BASE="$(mktemp -d)"
  export HOME="$TMPDIR_BASE"

  local skills="$TMPDIR_BASE/.config/opencode/skills"
  mkdir -p "$skills/as-setup"
  mkdir -p "$skills/as-new/templates"

  ln -s "$REAL_SETUP"                  "$skills/as-setup/setup.sh"
  ln -s "$REAL_COMMANDS_DIR"           "$skills/as-setup/opencode-commands"
  ln -s "$REAL_CONFIG_TEMPLATE"        "$skills/as-new/templates/config-template.yml"
  ln -s "$REAL_TOOL_MAPPING_TEMPLATE"  "$skills/as-new/templates/tool-mapping-template.yml"

  MOCK_SETUP="$skills/as-setup/setup.sh"
  MOCK_SKILLS_DIR="$skills"
}

teardown() {
  export HOME="$ORIG_HOME"
  if [[ -n "$TMPDIR_BASE" && -d "$TMPDIR_BASE" ]]; then
    rm -rf "$TMPDIR_BASE"
  fi
  TMPDIR_BASE=""
}

# ---------------------------------------------------------------------------
# Helpers — assertions
# ---------------------------------------------------------------------------

fail() {
  local msg="$1"
  echo -e "  ${RED}FAIL${NC}: $msg"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  return 1
}

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

assert_dir_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "expected directory to exist: $dir"
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "expected file to exist: $file"
    return 1
  fi
}

assert_file_not_exists() {
  local file="$1"
  if [[ -f "$file" ]]; then
    fail "expected file NOT to exist: $file"
    return 1
  fi
}

assert_dir_not_exists() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    fail "expected directory NOT to exist: $dir"
    return 1
  fi
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    fail "expected '$file' to contain '$pattern'"
    return 1
  fi
}

assert_file_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    fail "expected '$file' NOT to contain '$pattern'"
    return 1
  fi
}

assert_exit_code() {
  local expected="$1"
  shift
  "$@" >/dev/null 2>&1
  local actual=$?
  if [[ "$actual" -ne "$expected" ]]; then
    fail "expected exit code $expected but got $actual for: $*"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Test runner
# ---------------------------------------------------------------------------

run_test() {
  local test_fn="$1"
  CURRENT_TEST="$test_fn"
  TESTS_RUN=$((TESTS_RUN + 1))

  echo -n "[$TESTS_RUN] $test_fn ... "

  # Run the test function in a subshell so a failure doesn't abort the suite.
  local output
  output="$( "$test_fn" 2>&1 )"
  local rc=$?

  if [[ $rc -eq 0 ]]; then
    echo -e "${GREEN}PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    # Indent the assertion output
    if [[ -n "$output" ]]; then
      echo "$output" | sed 's/^/  /'
    fi
  fi

  # Always clean up — even if the test forgot to
  teardown
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_creates_auto_scrum_dir() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_dir_exists "$HOME/.auto-scrum"            || return 1
  assert_dir_exists "$HOME/.auto-scrum/features"    || return 1
  assert_dir_exists "$HOME/.auto-scrum/cross-feature" || return 1
}

test_creates_config_from_template() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_exists "$HOME/.auto-scrum/config.yml"           || return 1
  assert_file_contains "$HOME/.auto-scrum/config.yml" "auto_scrum:" || return 1
  assert_file_contains "$HOME/.auto-scrum/config.yml" "project:"   || return 1
}

test_substitutes_skills_dir() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_contains "$HOME/.auto-scrum/config.yml" "skills_dir: $MOCK_SKILLS_DIR" || return 1
}

test_creates_tool_mapping() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_exists "$HOME/.auto-scrum/tool-mapping.yml"                    || return 1
  assert_file_contains "$HOME/.auto-scrum/tool-mapping.yml" "copilot:"       || return 1
  assert_file_contains "$HOME/.auto-scrum/tool-mapping.yml" "opencode:"      || return 1
}

test_no_overwrite_config() {
  setup_copilot_mock
  mkdir -p "$HOME/.auto-scrum"
  echo "SENTINEL_CONFIG_VALUE" > "$HOME/.auto-scrum/config.yml"
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_contains "$HOME/.auto-scrum/config.yml" "SENTINEL_CONFIG_VALUE" || return 1
}

test_no_overwrite_tool_mapping() {
  setup_copilot_mock
  mkdir -p "$HOME/.auto-scrum"
  echo "SENTINEL_TOOL_MAPPING_VALUE" > "$HOME/.auto-scrum/tool-mapping.yml"
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_contains "$HOME/.auto-scrum/tool-mapping.yml" "SENTINEL_TOOL_MAPPING_VALUE" || return 1
}

test_fails_missing_config_template() {
  setup_copilot_mock
  # Remove the config template symlink
  rm "$MOCK_SKILLS_DIR/as-new/templates/config-template.yml"
  assert_exit_code 1 bash "$MOCK_SETUP" || return 1
}

test_fails_missing_tool_mapping_template() {
  setup_copilot_mock
  # Remove the tool-mapping template symlink
  rm "$MOCK_SKILLS_DIR/as-new/templates/tool-mapping-template.yml"
  assert_exit_code 1 bash "$MOCK_SETUP" || return 1
}

test_opencode_copies_commands() {
  setup_opencode_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_dir_exists "$HOME/.config/opencode/commands"                       || return 1
  assert_file_exists "$HOME/.config/opencode/commands/as-new.md"            || return 1
  assert_file_exists "$HOME/.config/opencode/commands/as-pipeline.md"       || return 1
}

test_copilot_no_commands() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_dir_not_exists "$HOME/.config/opencode/commands" || return 1
}

test_opencode_no_overwrite_commands() {
  setup_opencode_mock
  mkdir -p "$HOME/.config/opencode/commands"
  echo "SENTINEL_COMMAND_VALUE" > "$HOME/.config/opencode/commands/as-new.md"
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_contains "$HOME/.config/opencode/commands/as-new.md" "SENTINEL_COMMAND_VALUE" || return 1
}

test_opencode_sets_platform() {
  setup_opencode_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1
  assert_file_contains "$HOME/.auto-scrum/config.yml" "platform: opencode"    || return 1
  assert_file_not_contains "$HOME/.auto-scrum/config.yml" "platform: copilot" || return 1
}

test_full_idempotency() {
  setup_copilot_mock
  bash "$MOCK_SETUP" >/dev/null 2>&1 || { fail "first run exited non-zero"; return 1; }

  # Snapshot the filesystem state after the first run
  local snapshot_1
  snapshot_1="$(find "$HOME/.auto-scrum" -type f | sort | xargs md5sum 2>/dev/null || find "$HOME/.auto-scrum" -type f | sort | xargs md5 2>/dev/null)"

  bash "$MOCK_SETUP" >/dev/null 2>&1 || { fail "second run exited non-zero"; return 1; }

  local snapshot_2
  snapshot_2="$(find "$HOME/.auto-scrum" -type f | sort | xargs md5sum 2>/dev/null || find "$HOME/.auto-scrum" -type f | sort | xargs md5 2>/dev/null)"

  if [[ "$snapshot_1" != "$snapshot_2" ]]; then
    fail "filesystem state changed between first and second run"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

echo ""
echo "=== setup.sh test suite ==="
echo ""

run_test test_creates_auto_scrum_dir
run_test test_creates_config_from_template
run_test test_substitutes_skills_dir
run_test test_creates_tool_mapping
run_test test_no_overwrite_config
run_test test_no_overwrite_tool_mapping
run_test test_fails_missing_config_template
run_test test_fails_missing_tool_mapping_template
run_test test_opencode_copies_commands
run_test test_copilot_no_commands
run_test test_opencode_no_overwrite_commands
run_test test_opencode_sets_platform
run_test test_full_idempotency

echo ""
echo "---"
echo -e "Total: $TESTS_RUN  ${GREEN}Passed: $TESTS_PASSED${NC}  ${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi
exit 0
