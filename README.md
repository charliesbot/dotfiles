# 🤖 charliesbot's Dotfiles

---

## Bootstrap Installation

Ready to get started? Follow the instructions for your operating system.

### Fedora

1.  **Install Prerequisites**

    ```bash
    sudo dnf install -y git gh
    ```

2.  **Authenticate with GitHub**

    This command will open a browser for you to log in and will offer to set up an SSH key for you.

    ```bash
    gh auth login --web --git-protocol ssh
    ```

3.  **Clone the Dotfiles Repository**

    ```bash
    gh repo clone charliesbot/dotfiles ~/dotfiles
    ```

4.  **Run the Fedora Installation Script**

    For a deep dive into what this script does, check out the [Fedora README](./fedora/README.md).

    ```bash
    cd ~/dotfiles
    bash fedora/install-fedora.sh
    ```

### macOS

1.  **Install Xcode Command Line Tools**

    You'll need the Xcode Command Line Tools to get `git`. Run this command:

    ```bash
    xcode-select --install
    ```

    A dialog will appear. Click **Install** and wait for it to complete (this may take a few minutes).

2.  **Clone the Repository**

    Use HTTPS to clone (no SSH setup needed yet):

    ```bash
    git clone https://github.com/charliesbot/dotfiles.git ~/dotfiles
    ```

3.  **Run the Installation Script**

    The installation script will handle the rest, including installing Homebrew and all other dependencies.

    ```bash
    cd ~/dotfiles
    bash macos/install-macos.sh
    ```

4.  **Authenticate with GitHub and Update Git Remote**

    After the script completes, set up GitHub authentication with SSH:

    ```bash
    gh auth login --web --git-protocol ssh
    ```

    - When asked for your preferred protocol, choose **SSH**.
    - When `gh` offers to change your existing remote from HTTPS to SSH, say **Yes**.

    This will reconfigure your local repository to use your new SSH key, allowing you to `push` and `pull` changes seamlessly.

    Alternatively, if `gh` doesn't prompt you, update the remote manually:

    ```bash
    cd ~/dotfiles
    git remote set-url origin git@github.com:charliesbot/dotfiles.git
    ```

---

<div align="center">

**Made with ☕ and a whole lot of terminal time.**

</div>
