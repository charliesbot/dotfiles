#!/usr/bin/env bash

echo "This script will demonstrate what causes the graphical password dialog."
echo

echo "Step 1: Running a flatpak command that requires polkit authentication."
echo "This should trigger the graphical password dialog."
echo

# Use the same flatpak command from install-fedora.sh that triggers dialogs
flatpak remote-add --system --if-not-exists test-trigger https://dl.flathub.org/repo/flathub.flatpakrepo

RESULT=$?
echo

if [ $RESULT -eq 0 ]; then
    echo "Flatpak command succeeded."
    # Clean up the test remote
    flatpak remote-delete --system test-trigger --force 2>/dev/null || true
else
    echo "Flatpak command failed or was cancelled."
fi

echo "Script finished."
