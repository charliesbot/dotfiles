# charliesbot's Dotfiles

```
config/    — dotfiles that get symlinked (zshrc, nvim, ghostty, tmux, etc.)
setup/     — machine provisioning scripts (macos, fedora)
setup.sh   — entrypoint (detects OS, runs the right installer)
```

## Bootstrap

### macOS

```bash
xcode-select --install
git clone https://github.com/charliesbot/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash setup.sh
```

### Fedora

```bash
sudo dnf install -y git gh
gh auth login --web --git-protocol ssh
gh repo clone charliesbot/dotfiles ~/dotfiles
cd ~/dotfiles && bash setup.sh
```
