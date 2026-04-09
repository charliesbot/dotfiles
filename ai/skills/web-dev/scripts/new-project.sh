#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new Angular + Firebase side project with all conventions pre-configured.
# Requires: ng (Angular CLI), npm, git
# Assumes: ../assets/reset.css and ../assets/.prettierrc.json exist relative to this script.
#
# Usage:
#   ./new-project.sh <project-name>
#
# Example:
#   ./new-project.sh my-app
#
# Creates:
#   <project-name>/  — Angular project with CSS reset, ESLint, Prettier, and git initialized.
#
# Firebase, Firestore, auth, environments, etc. are added on demand
# as the project needs them — guided by the web-dev skill.

# --- Prerequisite checks ---
for cmd in ng npm git; do
    command -v "$cmd" &>/dev/null || {
        echo "Error: '$cmd' is not installed."
        exit 1
    }
done

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <project-name>"
    echo "  e.g. $0 my-app"
    exit 1
fi

PROJECT_NAME="$1"

# Validate: lowercase letters, numbers, and hyphens only
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: Project name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
    exit 1
fi

if [[ -d "$PROJECT_NAME" ]]; then
    echo "Error: Directory '$PROJECT_NAME' already exists."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESET_CSS="$SCRIPT_DIR/../assets/reset.css"
PRETTIER_RC="$SCRIPT_DIR/../assets/.prettierrc.json"

if [[ ! -f "$RESET_CSS" ]]; then
    echo "Error: Could not find reset.css at $RESET_CSS"
    exit 1
fi

if [[ ! -f "$PRETTIER_RC" ]]; then
    echo "Error: Could not find .prettierrc.json at $PRETTIER_RC"
    exit 1
fi

trap 'echo "Error: Setup failed. Cleaning up..."; rm -rf "$PROJECT_NAME"' ERR

echo -n "==> Creating Angular project: $PROJECT_NAME "
ng new "$PROJECT_NAME" --style=css --ssr --skip-git --skip-install --defaults --zoneless >/dev/null &
NG_PID=$!
while kill -0 $NG_PID 2>/dev/null; do
    printf '.'
    sleep 1
done
echo
# wait propagates ng new's exit code — ERR trap will fire on failure
wait $NG_PID

cd "$PROJECT_NAME"
# Update trap now that we've cd'd into the project directory
trap 'echo "Error: Setup failed. Cleaning up..."; cd ..; rm -rf "$PROJECT_NAME"' ERR

# --- CSS reset + custom properties ---
echo "==> Writing CSS reset and custom properties"
cp "$RESET_CSS" src/styles.css

# --- Install dependencies ---
# First pass: installs Angular deps so ng add schematics can run.
echo "==> Installing dependencies"
npm install

# --- Linting + Formatting ---
echo "==> Setting up ESLint and Prettier"
ng add angular-eslint --skip-confirmation --skip-installation
# Second pass: installs ESLint + Prettier after ng add updates package.json.
npm install prettier eslint-config-prettier --save-dev
cp "$PRETTIER_RC" .prettierrc.json

# --- Ensure .gitignore covers node_modules ---
if ! grep -q 'node_modules' .gitignore 2>/dev/null; then
    echo '/node_modules' >>.gitignore
fi

# --- Git init ---
echo "==> Initializing git repository"
git init
git add -A
git commit -m "Initial project setup

Scaffolded with new-project.sh. Angular with CSS reset, ESLint, and Prettier."

echo ""
echo "==> Done! Project '$PROJECT_NAME' is ready."
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. ng serve — start building"
echo ""
echo "The web-dev skill will guide you when you need Firebase, Firestore,"
echo "auth, environments, subdomain setup, or deployment."
