#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new TanStack Start + Firebase side project with all conventions pre-configured.
# Requires: npx, npm, git
# Assumes: ../assets/ exists alongside this script with reset.css, .prettierrc.json,
#          firestore.rules, and templates/ for our locked configs.
#
# Usage:
#   ./new-project.sh <project-name>
#
# Example:
#   ./new-project.sh my-app
#
# Creates:
#   <project-name>/  — TanStack Start project with our locked stack:
#                      - Vite + tanstackStart plugin
#                      - TanStack Router (file-based)
#                      - TanStack Query
#                      - Zod
#                      - CSS reset + tokens + globals
#                      - ESLint flat config + Prettier
#                      - Firebase wrapper (lib/firebase.ts) ready to receive config
#                      - apphosting.yaml ready for App Hosting deploy
#                      - firestore.rules locked down
#                      - git initialized
#
# Firebase project, DNS subdomain, App Hosting backend, etc. are added on demand
# as the project needs them — guided by the web-dev skill.

# --- Prerequisite checks ---
for cmd in npx npm git; do
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
ASSETS="$SCRIPT_DIR/../assets"
TEMPLATES="$ASSETS/templates"

for required in \
    "$ASSETS/reset.css" \
    "$ASSETS/.prettierrc.json" \
    "$ASSETS/firestore.rules" \
    "$TEMPLATES/apphosting.yaml" \
    "$TEMPLATES/eslint.config.js" \
    "$TEMPLATES/vite.config.ts" \
    "$TEMPLATES/.env.example" \
    "$TEMPLATES/src/lib/firebase.ts" \
    "$TEMPLATES/src/lib/firebase-admin.ts" \
    "$TEMPLATES/src/lib/query-client.ts" \
    "$TEMPLATES/src/styles/tokens.css" \
    "$TEMPLATES/src/styles/globals.css" \
    "$TEMPLATES/src/routes/__root.tsx"; do
    if [[ ! -f "$required" ]]; then
        echo "Error: Missing required template: $required"
        exit 1
    fi
done

trap 'echo "Error: Setup failed. Cleaning up..."; rm -rf "$PROJECT_NAME"' ERR

# --- Create the TanStack Start project (alpha CLI) ---
# `tanstack create` is the official scaffolder. It's alpha; if flags change,
# fall back to `npm create vite@latest` + manual @tanstack/start install.
echo "==> Creating TanStack Start project: $PROJECT_NAME"
npx --yes @tanstack/create-start@latest "$PROJECT_NAME" --template typescript --no-git --skip-install

cd "$PROJECT_NAME"
trap 'echo "Error: Setup failed. Cleaning up..."; cd ..; rm -rf "$PROJECT_NAME"' ERR

# --- Drop in our locked configs (overwriting CLI defaults) ---
echo "==> Applying locked configs"

mkdir -p src/lib src/styles src/routes src/components src/features

cp "$TEMPLATES/vite.config.ts" vite.config.ts
cp "$TEMPLATES/eslint.config.js" eslint.config.js
cp "$TEMPLATES/.env.example" .env.example
cp "$TEMPLATES/apphosting.yaml" apphosting.yaml
cp "$ASSETS/firestore.rules" firestore.rules
cp "$ASSETS/.prettierrc.json" .prettierrc.json

cp "$ASSETS/reset.css" src/styles/reset.css
cp "$TEMPLATES/src/styles/tokens.css" src/styles/tokens.css
cp "$TEMPLATES/src/styles/globals.css" src/styles/globals.css

cp "$TEMPLATES/src/lib/firebase.ts" src/lib/firebase.ts
cp "$TEMPLATES/src/lib/firebase-admin.ts" src/lib/firebase-admin.ts
cp "$TEMPLATES/src/lib/query-client.ts" src/lib/query-client.ts

cp "$TEMPLATES/src/routes/__root.tsx" src/routes/__root.tsx

# --- gitignore additions ---
{
    echo ''
    echo '# Local env'
    echo '.env.local'
    echo ''
    echo '# Generated route tree'
    echo 'src/routeTree.gen.ts'
    echo ''
    echo '# Build output'
    echo '.output'
} >>.gitignore

# --- Install dependencies ---
echo "==> Installing dependencies"
npm install
npm install firebase zod
npm install --save-dev \
    @eslint/js \
    typescript-eslint \
    eslint-plugin-react \
    eslint-plugin-react-hooks \
    eslint-config-prettier \
    prettier \
    vite-tsconfig-paths

# --- Server-side admin SDK (used only inside *.server.ts) ---
npm install firebase-admin

# --- Git init ---
echo "==> Initializing git"
git init -q
git add -A
git commit -qm "Initial project setup

Scaffolded with new-project.sh — TanStack Start + Firebase, locked stack."

cat <<EOF

==> Done! Project '$PROJECT_NAME' is ready.

Next steps:
  1. cd $PROJECT_NAME
  2. cp .env.example .env.local  # then fill in Firebase config (use firebase_get_sdk_config MCP)
  3. npm run dev

Firebase project, App Hosting backend, DNS, Cloud Functions, and Firestore rules
deploy are added on demand — guided by the web-dev skill.
EOF
