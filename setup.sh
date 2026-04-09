#!/usr/bin/env bash

# Entrypoint: detects the OS and runs the appropriate setup script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_command() {
    command -v "$1" &>/dev/null
}

os_type=""

if [[ "$(uname)" == "Darwin" ]]; then
    os_type="macOS"
elif check_command dnf; then
    os_type="Fedora"
else
    echo "Unsupported OS. Only macOS and Fedora are supported."
    exit 1
fi

echo "$os_type detected. Starting setup..."

case $os_type in
"macOS")
    bash "$SCRIPT_DIR/setup/macos/install-macos.sh"
    ;;
"Fedora")
    bash "$SCRIPT_DIR/setup/fedora/install-fedora.sh"
    ;;
esac
