#!/bin/bash

# WSL Ubuntu installer for the Fish-first dotfiles (Homebrew on Linux)
# Run via the root install.sh, or directly: bash wsl/install.sh
# Author: Atakan Zengin

set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

BREW_PREFIX="/home/linuxbrew/.linuxbrew"

if [ "$FORCE_OS" != "wsl" ] && ! grep -qi microsoft /proc/version 2>/dev/null; then
    print_error "This script is designed for WSL Ubuntu only."
fi

if [ "$(id -u)" -eq 0 ]; then
    print_error "Run this as your normal user, not root (Homebrew refuses to run as root)."
fi

print_banner "WSL Ubuntu"

# Cache sudo credentials up front (Homebrew's non-interactive install needs them)
sudo -v < /dev/tty

# Homebrew prerequisites and Python build dependencies (for pyenv)
print_step "🐧 Installing apt prerequisites..."
sudo apt-get update
sudo apt-get install -y \
    build-essential procps curl file git \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev liblzma-dev libncurses-dev tk-dev xz-utils locales

# config.fish sets LANG/LC_ALL to en_US.UTF-8, which minimal WSL images don't ship
if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
    print_step "🌐 Generating en_US.UTF-8 locale..."
    sudo locale-gen en_US.UTF-8
fi

# Install Homebrew if not installed
if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
    print_step "🍺 Installing Homebrew on Linux..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew already installed"
fi

eval "$("$BREW_PREFIX/bin/brew" shellenv)"
if ! grep -q "$BREW_PREFIX/bin/brew shellenv" "$HOME/.profile" 2>/dev/null; then
    echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.profile"
    print_success "Added Homebrew to ~/.profile (bash fallback)"
fi

# Install WSL-only formulae (no casks on Linux)
print_step "📦 Installing WSL packages..."
brew bundle --file="$DOTFILES_DIR/wsl/Brewfile"

run_common_steps "wsl"

# Optional /etc/wsl.conf (systemd, interop)
if ! cmp -s "$DOTFILES_DIR/wsl/wsl.conf" /etc/wsl.conf; then
    if confirm "Install wsl/wsl.conf to /etc/wsl.conf (enables systemd)?"; then
        [ -f /etc/wsl.conf ] && sudo cp /etc/wsl.conf /etc/wsl.conf.backup
        sudo cp "$DOTFILES_DIR/wsl/wsl.conf" /etc/wsl.conf
        print_success "Installed /etc/wsl.conf - run 'wsl --shutdown' from Windows to apply"
    fi
fi

# Windows Terminal profile (copied, since Windows can't follow WSL symlinks)
WIN_LOCALAPPDATA_RAW="$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r' || true)"
WIN_LOCALAPPDATA=""
if [ -n "$WIN_LOCALAPPDATA_RAW" ]; then
    WIN_LOCALAPPDATA="$(wslpath "$WIN_LOCALAPPDATA_RAW" 2>/dev/null || true)"
fi
if [ -n "$WIN_LOCALAPPDATA" ] && [ -d "$WIN_LOCALAPPDATA" ]; then
    FRAGMENT_DIR="$WIN_LOCALAPPDATA/Microsoft/Windows Terminal/Fragments/dotfiles"
    mkdir -p "$FRAGMENT_DIR"
    sed -e "s/wsl.exe -d Ubuntu/wsl.exe -d ${WSL_DISTRO_NAME:-Ubuntu}/" \
        -e "s/Fish (Ubuntu)/Fish (${WSL_DISTRO_NAME:-Ubuntu})/" \
        "$DOTFILES_DIR/wsl/windows-terminal/profile.json" > "$FRAGMENT_DIR/profile.json"
    print_success "Installed Windows Terminal profile 'Fish (${WSL_DISTRO_NAME:-Ubuntu})'"
else
    print_warning "Couldn't locate Windows %LOCALAPPDATA% - see README for the manual Windows Terminal setup"
fi

print_footer
echo
echo -e "${CYAN}🪟 Windows-side steps:${NC}"
echo "• Install 'JetBrainsMono Nerd Font' on Windows (https://www.nerdfonts.com/font-downloads) for prompt icons"
echo "• Restart Windows Terminal and pick the 'Fish (${WSL_DISTRO_NAME:-Ubuntu})' profile (set it as default in Settings)"
echo "• Docker: enable Docker Desktop → Settings → Resources → WSL integration for this distro"
