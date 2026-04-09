# charliesbot's Dotfiles

---

## Repo Structure

```
config/    — dotfiles that get symlinked (zshrc, nvim, ghostty, tmux, etc.)
setup/     — machine provisioning scripts (macos, fedora)
setup.sh   — entrypoint (detects OS, runs the right installer)
```

## Bootstrap Installation

### Fedora

1.  **Install Prerequisites**

    ```bash
    sudo dnf install -y git gh
    ```

2.  **Authenticate with GitHub**

    ```bash
    gh auth login --web --git-protocol ssh
    ```

3.  **Clone the Dotfiles Repository**

    ```bash
    gh repo clone charliesbot/dotfiles ~/dotfiles
    ```

4.  **Run the Installation Script**

    ```bash
    cd ~/dotfiles
    bash setup.sh
    ```

### macOS

1.  **Install Xcode Command Line Tools**

    ```bash
    xcode-select --install
    ```

2.  **Clone the Repository**

    ```bash
    git clone https://github.com/charliesbot/dotfiles.git ~/dotfiles
    ```

3.  **Run the Installation Script**

    ```bash
    cd ~/dotfiles
    bash setup.sh
    ```

4.  **Authenticate with GitHub and Update Git Remote**

    After the script completes, set up GitHub authentication with SSH:

    ```bash
    gh auth login --web --git-protocol ssh
    ```

    When asked for your preferred protocol, choose **SSH**.
    When `gh` offers to change your existing remote from HTTPS to SSH, say **Yes**.

    Alternatively, update the remote manually:

    ```bash
    cd ~/dotfiles
    git remote set-url origin git@github.com:charliesbot/dotfiles.git
    ```
