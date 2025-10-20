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

1.  **Clone the Repository**

    You'll need `git` to be installed. It typically comes with the Xcode Command Line Tools.

    ```bash
    git clone https://github.com/charliesbot/dotfiles.git ~/dotfiles
    ```

2.  **Run the Installation Script**

    The installation script will handle the rest, including installing Homebrew and all other dependencies.

    ```bash
    cd ~/dotfiles
    bash install.sh
    ```

3.  **Authenticate and Update Git Remote**

    This final step is crucial for pushing changes back to your repository.

    ```bash
    gh auth login --web --git-protocol ssh
    ```

    - When asked for your preferred protocol, choose **SSH**.
    - When `gh` offers to change your existing remote from HTTPS to SSH, say **Yes**.

    This will reconfigure your local repository to use your new SSH key, allowing you to `push` and `pull` changes seamlessly.

---

<div align="center">

**Made with ☕ and a whole lot of terminal time.**

</div>

