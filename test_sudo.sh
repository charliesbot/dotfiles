#!/usr/bin/env bash

echo "--- Sudo Keep-Alive & Polkit Test ---"

# 1. Invalidate any existing sudo timestamp for a clean test.
echo "Resetting sudo timestamp with 'sudo -k'..."
sudo -k
echo

# 2. Ask for the password once to start the timer.
echo "Please enter your password for sudo to begin the test."
sudo -v
if [ $? -ne 0 ]; then
  echo "Failed to get sudo privileges. Aborting test."
  exit 1
fi
echo "Sudo timestamp acquired."
echo

# 3. Create temporary polkit rule to allow passwordless operations
echo "Creating temporary polkit rule..."
sudo tee /etc/polkit-1/rules.d/99-temporary-nopasswd.rules >/dev/null <<EOF
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF
echo "Polkit rule created."
echo

# 4. Start the keep-alive loop in the background.
(
  while true; do
    sudo -n true
    sleep 60
  done
) &
KEEPALIVE_PID=$!
# Ensure cleanup on exit
trap "kill $KEEPALIVE_PID &> /dev/null; sudo rm -f /etc/polkit-1/rules.d/99-temporary-nopasswd.rules; echo; echo 'Test finished and cleanup complete.'" EXIT

echo "Keep-alive process started (PID: $KEEPALIVE_PID)."
echo

# 5. Wait for 90 seconds.
echo "Now waiting for 90 seconds..."
sleep 90
echo "Wait complete."
echo

# 6. Check if sudo access is still available without a password.
echo "--- Test 1: Sudo Keep-Alive ---"
echo "Checking sudo status with 'sudo -n whoami'..."
if sudo -n whoami &> /dev/null; then
  echo "✅ SUCCESS! Sudo privileges are still active."
else
  echo "❌ FAILURE! Sudo privileges have expired."
fi
echo

# 7. Check if the graphical dialog is suppressed for flatpak commands.
echo "--- Test 2: Graphical Dialog Suppression (Flatpak) ---"
echo "Now running 'flatpak remote-add --system'."
echo "If the fix works, you should NOT see a graphical dialog."
echo "You might be prompted for a password here IN THE TERMINAL."
echo "Please observe the behavior."
echo "---"
flatpak remote-add --system --if-not-exists test-fix https://dl.flathub.org/repo/flathub.flatpakrepo
FLATPAK_RESULT=$?
if [ $FLATPAK_RESULT -eq 0 ]; then
    echo "Flatpak command succeeded."
    # Clean up the test remote
    flatpak remote-delete --system test-fix --force 2>/dev/null || true
fi
echo "---"
read -p "Did a GRAPHICAL dialog appear? (y/N): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "❌ FAILURE! Graphical dialog was triggered."
else
    echo "✅ SUCCESS! Graphical dialog was suppressed."
fi

