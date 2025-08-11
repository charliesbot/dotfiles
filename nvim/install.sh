#!/bin/bash

# Kickstart.nvim Installation Script
# This script creates symlinks from this directory to ~/.config/nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

echo "Installing kickstart.nvim configuration..."

# Create ~/.config/nvim directory if it doesn't exist
mkdir -p "$NVIM_CONFIG_DIR"

# Backup existing config if it exists and is not a symlink
if [ -e "$NVIM_CONFIG_DIR" ] && [ ! -L "$NVIM_CONFIG_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing config to $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
    mkdir -p "$NVIM_CONFIG_DIR"
fi

# Function to create symlinks
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Remove existing file/symlink if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    echo "  Linked: $source -> $target"
}

# Symlink init.lua
if [ -f "$SCRIPT_DIR/init.lua" ]; then
    create_symlink "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"
fi

# Symlink lua directory
if [ -d "$SCRIPT_DIR/lua" ]; then
    create_symlink "$SCRIPT_DIR/lua" "$NVIM_CONFIG_DIR/lua"
fi

# Symlink doc directory
if [ -d "$SCRIPT_DIR/doc" ]; then
    create_symlink "$SCRIPT_DIR/doc" "$NVIM_CONFIG_DIR/doc"
fi

echo "Installation complete!"
echo "Your kickstart.nvim configuration is now symlinked to ~/.config/nvim"
echo ""
echo "To uninstall, simply remove the symlinks:"
echo "  rm -rf ~/.config/nvim"