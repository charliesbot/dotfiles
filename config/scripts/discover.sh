#!/usr/bin/env bash
# Project discovery — run from any project root.
# Outputs structured markdown: stack overview, directory tree, config files present, agent files.
# Deps: onefetch, tree

set -euo pipefail

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: discover [path]"
  echo "Discovers project metadata and outputs a structured markdown summary."
  exit 0
fi

ROOT="${1:-.}"
[[ -d "$ROOT" ]] || { echo "Error: $ROOT is not a directory" >&2; exit 1; }
ROOT="$(cd "$ROOT" && pwd)"

echo "# Project Discovery"
echo ""
echo "Root: $ROOT"
echo ""

# Stack overview
echo "## Stack"
echo ""
onefetch "$ROOT" --no-art 2>/dev/null || echo "(onefetch not available)"
echo ""

# Directory structure
echo "## Structure"
echo ""
echo '```'
tree -L 3 --dirsfirst -I 'node_modules|.git|dist|build|target|.gradle|__pycache__|.next|.nuxt|.output|coverage|.angular' "$ROOT" 2>/dev/null || echo "(tree not available)"
echo '```'
echo ""

# Config files present (AI reads them directly if needed)
echo "## Config Files"
echo ""
for f in package.json pyproject.toml Cargo.toml go.mod build.gradle.kts build.gradle Makefile Justfile justfile; do
  [[ -f "$ROOT/$f" ]] && echo "- $f"
done
echo ""

# Commands (extracted from build files)
echo "## Commands"
echo ""

has_commands=false

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

if [[ "$has_commands" == false ]]; then
  echo "(no Makefile or Justfile found)"
  echo ""
fi

# Existing agent files
echo "## Agent Files"
echo ""
for f in AGENTS.md CLAUDE.md .claude/CLAUDE.md CLAUDE.local.md GEMINI.md .gemini/GEMINI.md; do
  path="$ROOT/$f"
  if [[ -L "$path" ]]; then
    echo "- $f: symlink -> $(readlink "$path")"
  elif [[ -f "$path" ]]; then
    echo "- $f: $(wc -l <"$path" | tr -d ' ') lines"
  fi
done
