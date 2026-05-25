#!/bin/bash
# https://github.com/nagygergo/jetbrains-toolbox-install

set -euo pipefail

TMP_DIR="$(mktemp -d)"
INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
SYMLINK_DIR="$HOME/.local/bin"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "### INSTALL JETBRAINS TOOLBOX ###"

echo -e "\e[94mFetching the URL of the latest version...\e[39m"
ARCHIVE_URL=$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | jq -r '.TBA[0].downloads.linux.link')

if [[ -z "$ARCHIVE_URL" || "$ARCHIVE_URL" == "null" ]]; then
  echo "Failed to resolve JetBrains Toolbox download URL."
  exit 1
fi

ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")

echo -e "\e[94mDownloading $ARCHIVE_FILENAME...\e[39m"
wget -q --show-progress -cO "$TMP_DIR/$ARCHIVE_FILENAME" "$ARCHIVE_URL"

echo -e "\e[94mExtracting to $INSTALL_DIR...\e[39m"
mkdir -p "$INSTALL_DIR"
rm "$INSTALL_DIR/jetbrains-toolbox" 2>/dev/null || true
tar -xzf "$TMP_DIR/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
chmod +x "$INSTALL_DIR/bin/jetbrains-toolbox"

echo -e "\e[94mSymlinking to $SYMLINK_DIR/jetbrains-toolbox...\e[39m"
mkdir -p "$SYMLINK_DIR"
rm "$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
ln -s "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

if [[ -z "${CI:-}" ]]; then
  echo -e "\e[94mRunning for the first time to set-up...\e[39m"
  ("$INSTALL_DIR/bin/jetbrains-toolbox" &)
  echo -e "\n\e[32mDone! JetBrains Toolbox should now be running, in your application list, and you can run it in terminal as jetbrains-toolbox (ensure that $SYMLINK_DIR is on your PATH)\e[39m\n"
else
  echo -e "\n\e[32mDone! Running in a CI -- skipped launching the AppImage.\e[39m\n"
fi
