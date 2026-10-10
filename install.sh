#!/bin/bash

# Fish-First Dotfiles Setup Script
# One-click installation for macOS and WSL Ubuntu
# Author: Atakan Zengin
# GitHub: https://github.com/atakanzen/dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/atakanzen/dotfiles/main/install.sh | bash

set -e

REPO_URL="https://github.com/atakanzen/dotfiles.git"

# Use this checkout when run from one, otherwise clone to ~/.dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
        DOTFILES_DIR="$SCRIPT_DIR"
    else
        DOTFILES_DIR="$HOME/.dotfiles"
    fi
fi
export DOTFILES_DIR

# Detect the platform (FORCE_OS=macos|wsl overrides, e.g. for testing in a container)
detect_os() {
    if [ -n "$FORCE_OS" ]; then
        echo "$FORCE_OS"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "macos"
    elif [ "$(uname)" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    else
        echo "unsupported"
    fi
}

OS="$(detect_os)"
if [ "$OS" = "unsupported" ]; then
    echo "✗ Unsupported platform: this setup supports macOS and WSL Ubuntu only." >&2
    exit 1
fi

if ! command -v git &> /dev/null; then
    if [ "$OS" = "wsl" ]; then
        echo "==> Installing git..."
        sudo apt-get update && sudo apt-get install -y git
    else
        # On macOS, the git shim prompts for the Xcode Command Line Tools
        echo "✗ git not found. Run 'xcode-select --install', then re-run this script." >&2
        exit 1
    fi
fi

# Clone or update dotfiles repository
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> 📥 Cloning dotfiles repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
elif [ "$DOTFILES_DIR" = "$HOME/.dotfiles" ]; then
    echo "==> 🔄 Updating dotfiles repository..."
    git -C "$DOTFILES_DIR" pull --ff-only origin main
fi

exec bash "$DOTFILES_DIR/$OS/install.sh"
