#!/bin/bash

# macOS installer for the Fish-first dotfiles
# Run via the root install.sh, or directly: bash macos/install.sh
# Author: Atakan Zengin

set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only."
fi

print_banner "macOS"

# Install Xcode Command Line Tools if not installed
if ! xcode-select -p &> /dev/null; then
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and re-run this script."
    exit 1
else
    print_success "Xcode Command Line Tools already installed"
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    print_step "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew already installed"
fi

# Install macOS-only packages and applications
print_step "📦 Installing macOS packages and applications..."
brew bundle --file="$DOTFILES_DIR/macos/Brewfile"

run_common_steps "macos"

# Ghostty configuration
backup_and_link "macos/ghostty" ".config/ghostty"
if [ "$(command -v fish)" != "/opt/homebrew/bin/fish" ]; then
    print_warning "Fish is not at /opt/homebrew/bin/fish - update 'command' in macos/ghostty/config"
fi

print_footer
echo -e "${CYAN}👻 Ghostty is configured to launch Fish by default.${NC}"
