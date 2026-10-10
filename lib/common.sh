#!/bin/bash

# Shared installer library for the Fish-first dotfiles
# Sourced by macos/install.sh and wsl/install.sh - not meant to be run directly.
# Author: Atakan Zengin
# GitHub: https://github.com/atakanzen/dotfiles

# ===== IDENTITY =====
GIT_NAME="Atakan Zengin"
GIT_EMAIL="atakanzzengin@gmail.com"
GITHUB_USER="atakanzen"
DOTFILES_REPO="https://github.com/${GITHUB_USER}/dotfiles"

# Repo root (this file lives in <repo>/lib)
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Read a y/n answer from the terminal (works under `curl | bash`, where stdin is the script)
confirm() {
    local reply
    read -p "$1 (y/n): " -n 1 -r reply < /dev/tty
    echo
    [[ $reply =~ ^[Yy]$ ]]
}

print_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
 ______ _     _       _______ _          _
|  ____(_)   | |     |  _____(_)        | |
| |__   _ ___| |__   | |__    _ _ __ ___| |_
|  __| | / __| '_ \  |  __|  | | '__/ __| __|
| |    | \__ \ | | | | |     | | |  \__ \ |_
|_|    |_|___/_| |_| |_|     |_|_|  |___/\__|

🐟 Atakan Zengin's Fish-First Development Environment
EOF
    echo -e "${NC}"

    print_step "🐟 Starting Fish-first dotfiles installation ($1)..."
    echo -e "${PURPLE}This will set up a blazing-fast development environment with:${NC}"
    echo "  • Fish shell with modern plugins"
    echo "  • Starship prompt (Rust-powered speed)"
    echo "  • Complete development toolchain (Go, Node.js, Python, etc.)"
    echo "  • golangci-lint v2 configuration"
    echo "  • One-click package management with Homebrew"
    echo
}

# Install the cross-platform formulae (brew must already be on PATH)
brew_bundle_common() {
    print_step "📦 Installing cross-platform packages with Homebrew..."
    brew bundle --file="$DOTFILES_DIR/common/Brewfile"
}

# Symlink $DOTFILES_DIR/<source> to $HOME/<target>, backing up anything already there
backup_and_link() {
    local source="$DOTFILES_DIR/$1"
    local target="$HOME/$2"

    if [ ! -e "$source" ]; then
        print_warning "Source $source not found"
        return
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        print_success "$2 already linked"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        print_warning "Backing up existing $target to $target.backup"
        rm -rf "$target.backup"
        mv "$target" "$target.backup"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    print_success "Linked $1 -> $2"
}

check_core_tools() {
    for tool in fish starship eza; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "$tool installation failed. Please check the Brewfiles."
        fi
        print_success "$tool installed"
    done
}

# Link configs shared by every OS; $1 is the OS directory (macos or wsl)
link_common_configs() {
    local os_dir="$1"

    print_step "🔗 Creating symlinks for configuration files..."
    mkdir -p "$HOME/.config/fish/functions" "$HOME/.config/fish/completions" "$HOME/.config/fish/conf.d"

    # Fish configuration
    backup_and_link "common/fish/config.fish" ".config/fish/config.fish"
    backup_and_link "common/fish/fish_plugins" ".config/fish/fish_plugins"
    backup_and_link "$os_dir/fish/os.fish" ".config/fish/conf.d/os.fish"

    # Starship configuration
    backup_and_link "common/starship/starship.toml" ".config/starship.toml"

    # Git configuration
    backup_and_link "common/git/.gitconfig" ".gitconfig"
    backup_and_link "common/git/.gitignore_global" ".gitignore_global"

    # Node configuration
    backup_and_link "common/node/.npmrc" ".npmrc"

    # Go configuration (golangci-lint)
    backup_and_link "common/go/.golangci.yml" ".golangci.yml"
}

setup_fish_plugins() {
    # Fisher itself comes from the Brewfile; bootstrap it only if that failed
    if ! fish -c "type -q fisher"; then
        print_step "🎣 Installing Fisher plugin manager..."
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fi

    print_step "🔌 Installing Fish plugins..."
    fish -c "fisher update"
    print_success "Fish plugins installed"
}

setup_dev_environments() {
    print_step "🟢 Setting up Node.js environment..."
    fish -c "
        # Install latest LTS Node.js
        nvm install lts
        nvm use lts
        set -U nvm_default_version lts

        # Install global packages
        npm install -g pnpm typescript @types/node prettier eslint
    " 2>/dev/null || print_warning "Node.js setup encountered issues, please run 'nvm install lts' manually in Fish"
    print_success "Node.js environment configured"

    print_step "🐍 Setting up Python environment..."
    if command -v pyenv &> /dev/null; then
        # Install latest Python
        LATEST_PYTHON=$(pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
        if [ ! -d "$HOME/.pyenv/versions/$LATEST_PYTHON" ]; then
            print_info "Installing Python $LATEST_PYTHON (this may take a few minutes)..."
            pyenv install "$LATEST_PYTHON" || print_warning "Python installation failed, you can install it manually later"
        fi
        pyenv global "$LATEST_PYTHON" 2>/dev/null || true

        # Install common packages
        pip3 install --upgrade pip poetry black isort flake8 mypy 2>/dev/null || print_warning "Some Python packages failed to install"
        print_success "Python environment configured"
    fi

    print_step "🔵 Setting up Go environment..."
    if command -v go &> /dev/null; then
        # Install common Go tools
        go install golang.org/x/tools/gopls@latest
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        go install github.com/air-verse/air@latest
        print_success "Go environment configured with golangci-lint v2"
    fi
}

setup_ssh_key() {
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        print_step "🔑 Setting up SSH key..."
        if confirm "Generate SSH key for GitHub?"; then
            ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""

            # Start ssh-agent and add key
            eval "$(ssh-agent -s)"
            ssh-add "$HOME/.ssh/id_ed25519"

            print_success "SSH key generated at ~/.ssh/id_ed25519.pub"
            print_warning "Don't forget to add your SSH key to GitHub:"
            print_warning "https://github.com/settings/keys"
            echo
            echo -e "${CYAN}Your public key:${NC}"
            cat "$HOME/.ssh/id_ed25519.pub"
            echo
        fi
    fi
}

set_default_shell() {
    print_step "🐟 Setting Fish as default shell..."
    FISH_PATH=$(command -v fish)

    # Add Fish to /etc/shells if not already there
    if ! grep -qx "$FISH_PATH" /etc/shells 2>/dev/null; then
        print_info "Adding Fish to /etc/shells (requires sudo)..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells
        print_success "Fish added to /etc/shells"
    fi

    # Change default shell
    if [ "$SHELL" != "$FISH_PATH" ]; then
        print_info "Changing default shell to Fish (requires password)..."
        chsh -s "$FISH_PATH" < /dev/tty
        print_success "Default shell changed to Fish"
        print_warning "You may need to restart your terminal or log out/in for the change to take effect"
    else
        print_success "Fish is already the default shell"
    fi
}

final_fish_config() {
    print_step "🎯 Final Fish configuration..."
    fish -c "
        # Set up environment variables
        set -Ux EDITOR code
        set -Ux VISUAL code

        # Go paths
        set -Ux GOPATH \$HOME/go
        set -Ux GOBIN \$GOPATH/bin

        # Add paths
        fish_add_path \$GOBIN
        fish_add_path \$HOME/.local/bin

        # Docker settings
        set -Ux DOCKER_BUILDKIT 1
        set -Ux COMPOSE_DOCKER_CLI_BUILD 1
    " 2>/dev/null || print_warning "Some Fish configuration failed, please check manually"

    print_success "Fish configuration completed!"
}

validate_install() {
    print_step "🔍 Validating installation..."

    # Check if Fish is properly set as default
    FISH_PATH=$(command -v fish)
    if [ "$SHELL" = "$FISH_PATH" ]; then
        print_success "Fish is set as default shell"
    else
        print_warning "Fish may not be the default shell yet (restart terminal or run 'exec fish')"
    fi

    # Check essential tools
    ESSENTIAL_TOOLS=("fish" "starship" "eza" "bat" "fd" "rg" "git")
    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_success "$tool is available"
        else
            print_warning "$tool not found"
        fi
    done

    if [ "$(git config --global user.email)" = "$GIT_EMAIL" ]; then
        print_success "Git configured for $GIT_NAME <$GIT_EMAIL>"
    else
        print_warning "Git identity is not $GIT_NAME <$GIT_EMAIL> - check ~/.gitconfig"
    fi

    print_success "Installation validation completed!"
}

print_footer() {
    echo
    echo -e "${GREEN}🎉 Atakan's Fish-first dotfiles installation completed successfully!${NC}"
    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "1. ${YELLOW}Restart your terminal${NC} (new Fish session will load automatically)"
    echo -e "2. Run ${YELLOW}'fish_config'${NC} to open the web-based configuration UI"
    echo -e "3. Try some abbreviations: ${YELLOW}'gs'${NC} (git status), ${YELLOW}'ll'${NC} (eza list)"
    echo "4. Add your SSH key to GitHub if you generated one"
    echo -e "5. Test your development tools: ${YELLOW}'go version'${NC}, ${YELLOW}'node --version'${NC}, ${YELLOW}'python3 --version'${NC}"
    echo -e "6. Test Go linting: ${YELLOW}'golangci-lint --version'${NC}"
    echo
    echo -e "${CYAN}💡 If you experience any issues:${NC}"
    echo -e "• Fish not default? Run: ${YELLOW}exec fish${NC} or restart terminal"
    echo "• Commands not found? Restart terminal to reload PATH"
    echo -e "• Need help? Check: ${YELLOW}${DOTFILES_REPO}#troubleshooting${NC}"
    echo
    echo -e "${YELLOW}Tip: Run 'update-all' anytime to update all your development tools!${NC}"
    echo -e "${BLUE}Repository: ${DOTFILES_REPO}${NC}"
}

# Steps every OS runs once brew is on PATH and OS packages are installed
run_common_steps() {
    local os_dir="$1"

    brew_bundle_common
    check_core_tools
    link_common_configs "$os_dir"
    setup_fish_plugins
    setup_dev_environments
    setup_ssh_key
    set_default_shell
    final_fish_config
    validate_install
}
