#!/usr/bin/env bash
# Discovers project metadata for AGENTS.md generation.
# Outputs a structured markdown summary of: stack, commands, structure, and existing agent files.
# Requires: onefetch, tree, bun
# Works on macOS and Linux.

set -euo pipefail

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: discover.sh [path]"
  echo "Discovers project metadata and outputs a structured markdown summary."
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSE=(bun run "${SCRIPT_DIR}/lib/parse.ts")

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

echo "# Project Discovery"
echo ""
echo "Root: $ROOT"
echo ""

# --- Stack (via onefetch JSON) ---
echo "## Stack"
echo ""
onefetch "$ROOT" --no-art --output json 2>/dev/null | "${PARSE[@]}" onefetch - || echo "(onefetch failed)"
echo ""

# --- Commands (only extract project-specific ones) ---
echo "## Commands"
echo ""

has_commands=false

# package.json scripts
# parse.ts exits 2 when no scripts found — && skips the section intentionally
if [[ -f "$ROOT/package.json" ]]; then
  pkg_output=$("${PARSE[@]}" package-json "$ROOT/package.json" 2>/dev/null) && {
    has_commands=true
    echo "### package.json scripts"
    echo "$pkg_output"
    echo ""
  }
fi

# Makefile targets
if [[ -f "$ROOT/Makefile" ]]; then
  has_commands=true
  echo "### Makefile targets"
  grep -E '^[a-zA-Z_-]+:' "$ROOT/Makefile" 2>/dev/null | sed 's/[: ].*//' | while read -r target; do
    echo "- $target"
  done
  echo ""
fi

# Justfile recipes
if [[ -f "$ROOT/Justfile" ]] || [[ -f "$ROOT/justfile" ]]; then
  has_commands=true
  justfile="${ROOT}/Justfile"
  [[ -f "$ROOT/justfile" ]] && justfile="${ROOT}/justfile"
  echo "### Justfile recipes"
  grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\s*:' "$justfile" 2>/dev/null | sed 's/[: ].*//' | while read -r target; do
    echo "- $target"
  done
  echo ""
fi

# pyproject.toml
if [[ -f "$ROOT/pyproject.toml" ]]; then
  has_commands=true
  echo "### pyproject.toml"
  "${PARSE[@]}" pyproject "$ROOT/pyproject.toml" || echo "(failed to parse pyproject.toml)"
  echo ""
fi

# Cargo.toml
if [[ -f "$ROOT/Cargo.toml" ]]; then
  has_commands=true
  echo "### Cargo"
  "${PARSE[@]}" cargo "$ROOT/Cargo.toml" || echo "(failed to parse Cargo.toml)"
  echo "- build: \`cargo build\`"
  echo "- test: \`cargo test\`"
  echo "- lint: \`cargo clippy\`"
  echo "- format: \`cargo fmt\`"
  echo ""
fi

# go.mod
if [[ -f "$ROOT/go.mod" ]]; then
  has_commands=true
  echo "### Go"
  "${PARSE[@]}" gomod "$ROOT/go.mod" || echo "(failed to parse go.mod)"
  echo "- build: \`go build ./...\`"
  echo "- test: \`go test ./...\`"
  echo "- lint: \`go vet ./...\`"
  echo ""
fi

# Gradle
if [[ -f "$ROOT/build.gradle.kts" ]] || [[ -f "$ROOT/build.gradle" ]]; then
  has_commands=true
  echo "### Gradle"
  echo "- build: \`./gradlew build\`"
  echo "- test: \`./gradlew test\`"
  echo "- lint: \`./gradlew lint\`" # Android projects
  gradle_file="$ROOT/build.gradle.kts"
  [[ ! -f "$gradle_file" ]] && gradle_file="$ROOT/build.gradle"
  if grep -q "spotless" "$gradle_file" 2>/dev/null; then
    echo "- format: \`./gradlew spotlessApply\`"
  fi
  echo ""
fi

if [[ "$has_commands" == false ]]; then
  echo "(no recognized build system found — check project root for build files)"
  echo ""
fi

# --- Structure ---
echo "## Structure"
echo ""
echo '```'
tree -L 3 --dirsfirst -I 'node_modules|.git|dist|build|target|.gradle|__pycache__|.next|.nuxt|.output|coverage|.angular|*-workspace' "$ROOT" 2>/dev/null
echo '```'
echo ""

# --- Existing Agent Files ---
echo "## Existing Agent Files"
echo ""

check_file() {
  local path="$1"
  local label="$2"
  if [[ -L "$path" ]]; then
    local target
    target=$(readlink "$path" 2>/dev/null || true)
    echo "- $label: symlink -> $target"
  elif [[ -f "$path" ]]; then
    local lines
    lines=$(wc -l <"$path" 2>/dev/null | tr -d ' ')
    echo "- $label: found ($lines lines)"
  else
    echo "- $label: not found"
  fi
}

check_file "$ROOT/AGENTS.md" "AGENTS.md"
check_file "$ROOT/CLAUDE.md" "CLAUDE.md"
check_file "$ROOT/.claude/CLAUDE.md" ".claude/CLAUDE.md"
check_file "$ROOT/CLAUDE.local.md" "CLAUDE.local.md"
check_file "$ROOT/GEMINI.md" "GEMINI.md"
check_file "$ROOT/.gemini/GEMINI.md" ".gemini/GEMINI.md"
check_file "$ROOT/.gemini/settings.json" ".gemini/settings.json"

echo ""
