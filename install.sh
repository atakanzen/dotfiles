#!/bin/bash

# Fish-First Dotfiles Setup Script
# One-click installation for modern macOS development environment
# Author: Gökhan Arkan
# GitHub: https://github.com/gokhanarkan/dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/gokhanarkan/dotfiles/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033echo "3. Try some abbreviations: ${YELLOW}'gs'${NC} (git status), ${YELLOW}'ll'${NC} (eza list)"1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

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

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only."
fi

echo -e "${PURPLE}"
cat << "EOF"
 ______ _     _       _______ _          _
|  ____(_)   | |     |  _____(_)        | |
| |__   _ ___| |__   | |__    _ _ __ ___| |_
|  __| | / __| '_ \  |  __|  | | '__/ __| __|
| |    | \__ \ | | | | |     | | |  \__ \ |_
|_|    |_|___/_| |_| |_|     |_|_|  |___/\__|

🐟 Gökhan Arkan's Fish-First Development Environment
EOF
echo -e "${NC}"

print_step "🐟 Starting Fish-first dotfiles installation..."
echo -e "${PURPLE}This will set up a blazing-fast development environment with:${NC}"
echo "  • Fish shell with modern plugins"
echo "  • Starship prompt (Rust-powered speed)"
echo "  • Complete development toolchain (Go, Node.js, Python, etc.)"
echo "  • Ghostty terminal optimization"
echo "  • golangci-lint v2 configuration"
echo "  • One-click package management"
echo

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

# Clone or update dotfiles repository
if [ ! -d "$DOTFILES_DIR" ]; then
    print_step "📥 Cloning dotfiles repository..."
    git clone https://github.com/gokhanarkan/dotfiles.git "$DOTFILES_DIR"
else
    print_step "🔄 Updating dotfiles repository..."
    cd "$DOTFILES_DIR" && git pull origin main
fi

cd "$DOTFILES_DIR"

# Function to check if a package is already installed
is_brew_installed() {
    brew list --formula "$1" &> /dev/null
}

is_cask_installed() {
    brew list --cask "$1" &> /dev/null
}

# Install packages from Brewfile with smart checking
print_step "📦 Installing packages with Homebrew..."
print_info "Checking existing installations first..."

# Check for some key packages to avoid unnecessary installs
if is_brew_installed "fish"; then
    print_success "Fish shell already installed"
else
    print_info "Fish shell will be installed"
fi

if is_cask_installed "google-chrome"; then
    print_success "Google Chrome already installed"
else
    print_info "Google Chrome will be installed"
fi

if is_cask_installed "visual-studio-code"; then
    print_success "VS Code already installed"
else
    print_info "VS Code will be installed"
fi

brew bundle --file="$DOTFILES_DIR/Brewfile"

# Install Fish shell if not installed
if ! command -v fish &> /dev/null; then
    print_error "Fish shell installation failed. Please check Brewfile."
else
    print_success "Fish shell installed"
fi

# Install Starship prompt
if ! command -v starship &> /dev/null; then
    print_error "Starship installation failed. Please check Brewfile."
else
    print_success "Starship prompt installed"
fi

# Ensure eza is installed (modern replacement for exa)
if ! command -v eza &> /dev/null; then
    print_error "eza installation failed. Please check Brewfile."
else
    print_success "eza installed (modern ls replacement)"
fi

# Setup Fish configuration directory
print_step "🐟 Setting up Fish configuration..."
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/fish/completions"

# Create symlinks for configuration files
print_step "🔗 Creating symlinks for configuration files..."

# Backup existing files
backup_and_link() {
    local source="$DOTFILES_DIR/$1"
    local target="$HOME/$2"

    if [ -f "$target" ] || [ -L "$target" ]; then
        print_warning "Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi

    if [ -f "$source" ]; then
        ln -sf "$source" "$target"
        print_success "Linked $1 -> $2"
    else
        print_warning "Source file $source not found"
    fi
}

# Fish configuration
backup_and_link "fish/config.fish" ".config/fish/config.fish"
backup_and_link "fish/fish_plugins" ".config/fish/fish_plugins"

# Ensure Fish config uses eza (not exa)
if [ -f "$HOME/.config/fish/config.fish" ]; then
    if grep -q "abbr.*exa" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        print_step "Updating fish abbreviations to use eza instead of exa..."
        sed -i '' 's/abbr -a \([^ ]*\) '\''exa/abbr -a \1 '\''eza/g' "$HOME/.config/fish/config.fish"
        print_success "Fish abbreviations updated to use eza"
    fi
fi

# Starship configuration
mkdir -p "$HOME/.config"
backup_and_link "starship/starship.toml" ".config/starship.toml"

# Git configuration
backup_and_link "git/.gitconfig" ".gitconfig"
backup_and_link "git/.gitignore_global" ".gitignore_global"

# Node configuration
backup_and_link "node/.npmrc" ".npmrc"

# Go configuration (golangci-lint)
backup_and_link ".golangci.yml" ".golangci.yml"

# Ghostty configuration
if [ -d "$DOTFILES_DIR/ghostty" ]; then
    rm -rf "$HOME/.config/ghostty"
    ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"

    # Ensure Ghostty config uses the correct Fish path
    FISH_PATH=$(which fish)
    if [ -f "$HOME/.config/ghostty/config" ] && [ -n "$FISH_PATH" ]; then
        # Update the Fish path in Ghostty config if needed
        sed -i '' "s|command = \"/opt/homebrew/bin/fish\"|command = \"$FISH_PATH\"|g" "$HOME/.config/ghostty/config"
    fi

    print_success "Linked Ghostty configuration (Fish shell default)"
fi

# Install Fisher plugin manager
print_step "🎣 Installing Fisher plugin manager..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install Fish plugins from fish_plugins file
print_step "🔌 Installing Fish plugins..."
if [ -f "$HOME/.config/fish/fish_plugins" ]; then
    fish -c "fisher update"
    print_success "Fish plugins installed"
else
    print_warning "fish_plugins file not found, installing essential plugins manually..."
    fish -c "
        fisher install jethrokuan/z
        fisher install PatrickF1/fzf.fish
        fisher install franciscolourenco/done
        fisher install jorgebucaran/nvm.fish
        fisher install joseluisq/gitnow
        fisher install wfxr/forgit
        fisher install jorgebucaran/autopair.fish
        fisher install gazorby/fish-abbreviation-tips
    "
fi

# Setup development environments
print_step "🟢 Setting up Node.js environment..."
if command -v fish &> /dev/null; then
    fish -c "
        # Install latest LTS Node.js
        nvm install lts
        nvm use lts
        set -U nvm_default_version lts

        # Install global packages
        npm install -g pnpm typescript @types/node prettier eslint
    " 2>/dev/null || print_warning "Node.js setup encountered issues, please run 'nvm install lts' manually in Fish"
    print_success "Node.js environment configured"
fi

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

# Configure Git with user-provided information
print_step "⚙️ Configuring Git..."
read -p "Enter your Git username: " GIT_USERNAME
read -p "Enter your Git email: " GIT_EMAIL

if [ -z "$GIT_USERNAME" ] || [ -z "$GIT_EMAIL" ]; then
    print_error "Git username and email are required"
fi

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
print_success "Git configured for $GIT_USERNAME <$GIT_EMAIL>"

# Configure GitHub username (optional)
read -p "Enter your GitHub username (optional, press Enter to skip): " GITHUB_USERNAME
if [ -n "$GITHUB_USERNAME" ]; then
    git config --global github.user "$GITHUB_USERNAME"
    print_success "GitHub user configured: $GITHUB_USERNAME"
fi

# Configure GitLab username (optional)
read -p "Enter your GitLab username (optional, press Enter to skip): " GITLAB_USERNAME
if [ -n "$GITLAB_USERNAME" ]; then
    git config --global gitlab.user "$GITLAB_USERNAME"
    print_success "GitLab user configured: $GITLAB_USERNAME"
fi

# Set up SSH key (optional)
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    # Backup .ssh folder if it exists
    if [ -d "$HOME/.ssh" ]; then
        print_step "📦 Backing up .ssh folder..."
        BACKUP_DIR="$HOME/.ssh.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.ssh" "$BACKUP_DIR"
        print_success ".ssh folder backed up to $BACKUP_DIR"
    fi

    print_step "🔑 Setting up SSH key..."
    read -p "Generate SSH key for GitHub? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
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

# Change default shell to Fish
print_step "🐟 Setting Fish as default shell..."
FISH_PATH=$(which fish)

# Add Fish to /etc/shells if not already there
if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
    print_info "Adding Fish to /etc/shells (requires sudo)..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
    print_success "Fish added to /etc/shells"
fi

# Change default shell
if [ "$SHELL" != "$FISH_PATH" ]; then
    print_info "Changing default shell to Fish (requires password)..."
    chsh -s "$FISH_PATH"
    print_success "Default shell changed to Fish"
    print_warning "You may need to restart your terminal or log out/in for the change to take effect"
else
    print_success "Fish is already the default shell"
fi

# Final Fish configuration
print_step "🎯 Final Fish configuration..."
fish -c "
    # Set up environment variables
    set -Ux EDITOR code
    set -Ux VISUAL code
    set -Ux BROWSER open

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

# Install fonts for better terminal experience
print_step "🔤 Installing programming fonts..."
echo "Fonts are being installed via Homebrew (this was included in the Brewfile)"

# Validation and final checks
print_step "🔍 Validating installation..."

# Check if Fish is properly set as default
CURRENT_SHELL=$(echo $SHELL)
FISH_PATH=$(which fish)
if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
    print_success "Fish is set as default shell"
else
    print_warning "Fish may not be the default shell yet (restart terminal or run 'exec fish')"
fi

# Check if eza is available and fish config uses it
if command -v eza &> /dev/null; then
    print_success "eza command available"
    if [ -f "$HOME/.config/fish/config.fish" ] && grep -q "eza" "$HOME/.config/fish/config.fish"; then
        print_success "Fish configuration uses eza"
    else
        print_warning "Fish configuration may not be using eza properly"
    fi
else
    print_error "eza not found - some abbreviations may not work"
fi

# Check essential tools
ESSENTIAL_TOOLS=("fish" "starship" "eza" "bat" "fd" "ripgrep" "git")
for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        print_success "$tool is available"
    else
        print_warning "$tool not found"
    fi
done

print_success "Installation validation completed!"

# Final success message
echo
echo -e "${GREEN}🎉 Gökhan's Fish-first dotfiles installation completed successfully!${NC}"
echo
echo -e "${CYAN}🚀 Your blazing-fast development environment is ready!${NC}"
echo
echo -e "${YELLOW}What's been installed:${NC}"
echo "  🐟 Fish shell as default with modern plugins"
echo "  🚀 Starship prompt (Rust-powered)"
echo "  🎣 Fisher plugin manager with essential plugins"
echo "  📦 Complete development toolchain (Go, Node.js, Python)"
echo "  🔧 Optimized configurations for all tools"
echo "  👻 Ghostty terminal configuration (Fish shell default)"
echo "  🔍 golangci-lint v2 configuration for Go projects"
echo
echo -e "${CYAN}Next steps:${NC}"
echo "1. ${YELLOW}Restart your terminal${NC} (new Fish session will load automatically)"
echo "2. Run ${YELLOW}'fish_config'${NC} to open the web-based configuration UI"
echo "3. Try some abbreviations: ${YELLOW}'gs'${NC} (git status), ${YELLOW}'ll'${NC} (eza list)"
echo "4. Add your SSH key to GitHub if you generated one"
echo "5. Test your development tools: ${YELLOW}'go version'${NC}, ${YELLOW}'node --version'${NC}, ${YELLOW}'python3 --version'${NC}"
echo "6. Test Go linting: ${YELLOW}'golangci-lint --version'${NC}"
echo
echo -e "${CYAN}💡 If you experience any issues:${NC}"
echo "• Fish not default? Run: ${YELLOW}exec fish${NC} or restart terminal"
echo "• Commands not found? Restart terminal to reload PATH"
echo "• Need help? Check: ${YELLOW}https://github.com/gokhanarkan/dotfiles#troubleshooting${NC}"
echo
echo -e "${PURPLE}Fish advantages you now have:${NC}"
echo "  ⚡ 4x faster shell startup than Zsh"
echo "  🎯 Intelligent autosuggestions out-of-the-box"
echo "  🌈 Syntax highlighting by default"
echo "  📝 Abbreviations that expand as you type"
echo "  🔍 Incredible tab completions"
echo "  🧠 Smart command history"
echo
echo -e "${GREEN}Welcome to the Fish shell! 🐟${NC}"
echo -e "${CYAN}Happy coding! 🚀${NC}"
echo
echo -e "${YELLOW}Tip: Run 'update-all' anytime to update all your development tools!${NC}"
echo -e "${BLUE}Repository: https://github.com/gokhanarkan/dotfiles${NC}"