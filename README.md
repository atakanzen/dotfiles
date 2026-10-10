# 🐟 Atakan's Fish-First Dotfiles

> A blazing-fast development environment for **macOS** and **WSL Ubuntu** built around Fish shell, optimized for Go, Python, JavaScript/TypeScript, and modern development workflows.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fish Shell](https://img.shields.io/badge/Fish-Shell-blue.svg)](https://fishshell.com/)
[![Starship](https://img.shields.io/badge/Prompt-Starship-purple.svg)](https://starship.rs/)
[![Go](https://img.shields.io/badge/Go-Ready-00ADD8.svg)](https://golang.org/)

**Author:** Atakan Zengin ([@atakanzen](https://github.com/atakanzen))
**Email:** atakanzzengin@gmail.com

## ⚡ Why Fish?

**4x faster than Zsh** • **Intelligent autosuggestions** • **Syntax highlighting out-of-the-box** • **Superior tab completions** • **Smart command history**

This setup gives you all the power of modern shell features without the complexity and slowdown of traditional setups.

## 🚀 Quick Install

The same one-liner works on **macOS** and **WSL Ubuntu**. It detects the platform and runs `macos/install.sh` or `wsl/install.sh`:

```bash
curl -fsSL https://raw.githubusercontent.com/atakanzen/dotfiles/main/install.sh | bash
```

Or from a local checkout:

```bash
git clone git@github.com:atakanzen/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

**That's it!** The script will automatically:

- Install Fish shell and set it as default
- Configure Starship prompt
- Install essential development tools
- Set up your development environment
- Configure Git with productivity shortcuts
- Install golangci-lint v2 configuration

## ✨ What's Included

### 🐟 Core Shell Experience

- **Fish Shell** - Fast, user-friendly, intelligent shell
- **Starship Prompt** - Rust-powered, beautiful, cross-shell prompt
- **Fisher** - Minimal, fast plugin manager
- **Ghostty Terminal** (macOS) - Pre-configured with Fish as default shell
- **Windows Terminal profile** (WSL) - Fish, JetBrainsMono Nerd Font, Catppuccin Mocha
- **Essential plugins** - Carefully curated for productivity

### 🛠 Development Stack

| Language    | Tools                        | Version Manager |
| ----------- | ---------------------------- | --------------- |
| **Go**      | gopls, golangci-lint v2, air | Homebrew        |
| **Node.js** | TypeScript, ESLint, Prettier | fnm (fast)      |
| **Python**  | poetry, black, isort, mypy   | pyenv           |
| **Ruby**    | Standard gems                | rbenv           |

### 📦 Package Management

- **Homebrew** - System packages on both platforms (Homebrew on Linux for WSL; casks/apps on macOS only)
- **pnpm** - Fast, efficient Node.js package manager (preferred over npm)
- **Fisher** - Lightweight Fish plugin manager

### ⚡ Modern CLI Tools

| Traditional | Modern Alternative | Benefits                       |
| ----------- | ------------------ | ------------------------------ |
| `ls`        | `eza`              | Git integration, colors, icons |
| `cat`       | `bat`              | Syntax highlighting, paging    |
| `grep`      | `ripgrep`          | Faster, smarter defaults       |
| `find`      | `fd`               | Simpler syntax, faster         |
| `cd`        | `z` (zoxide)       | Smart directory jumping        |

## 📁 Repository Structure

```
dotfiles/
├── install.sh              # Entry point: detects macOS / WSL and dispatches
├── lib/
│   └── common.sh           # Shared installer steps (links, Fisher, toolchains, shell)
├── common/                 # Configs shared by every platform
│   ├── Brewfile            # Cross-platform formulae (no casks)
│   ├── fish/
│   │   ├── config.fish     # Main Fish configuration
│   │   └── fish_plugins    # Plugin list for Fisher
│   ├── starship/starship.toml
│   ├── git/
│   │   ├── .gitconfig      # Git with productivity aliases
│   │   └── .gitignore_global
│   ├── node/.npmrc         # NPM configuration (pnpm preferred)
│   └── go/.golangci.yml    # golangci-lint v2 configuration
├── macos/
│   ├── install.sh          # Xcode CLT, Homebrew, apps, Ghostty
│   ├── Brewfile            # macOS-only formulae + casks
│   ├── fish/os.fish        # -> ~/.config/fish/conf.d/os.fish
│   └── ghostty/config      # Terminal settings (Fish shell default)
├── wsl/
│   ├── install.sh          # apt prerequisites, Homebrew on Linux, Windows Terminal
│   ├── Brewfile            # Linux-only extras (never casks)
│   ├── fish/os.fish        # -> ~/.config/fish/conf.d/os.fish
│   ├── windows-terminal/profile.json  # Windows Terminal fragment
│   └── wsl.conf            # Optional /etc/wsl.conf (systemd, interop)
└── docs/
    └── FISH_GUIDE.md       # Fish shell productivity guide
```

Platform-specific shell settings (Homebrew path, `BROWSER`, clipboard, networking helpers) live in `os.fish`, which Fish loads from `conf.d/` before `config.fish`.

## 🪟 WSL Ubuntu Notes

- **Homebrew on Linux** is installed to `/home/linuxbrew/.linuxbrew`. apt is only used for Homebrew's prerequisites and Python build dependencies.
- **Docker** isn't installed inside WSL. Enable *Docker Desktop → Settings → Resources → WSL integration* for your distro.
- **Fonts** must be installed on the Windows side: install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) for prompt icons.
- **Windows Terminal**: the installer copies `wsl/windows-terminal/profile.json` as a [settings fragment](https://learn.microsoft.com/windows/terminal/json-fragment-extensions) to `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\`. It adds a *Fish (<distro>)* profile; set it as the default profile in Windows Terminal settings. If the copy fails, place the file there manually.
- **Clipboard / open**: `pbcopy`, `pbpaste` and `open` work via `clip.exe`, PowerShell and `explorer.exe`.
- **`$WINHOME`** points at your Windows user directory (`winhome` abbreviation jumps there).
- **`/etc/wsl.conf`**: the installer offers to enable systemd; run `wsl --shutdown` from Windows afterwards.

## 🎯 Essential Abbreviations

> Fish abbreviations expand when you press space, showing you the full command

### Quick Navigation

```fish
..      # cd ..
...     # cd ../..
ll      # eza -la --git --icons
tree    # eza --tree --icons
```

### Git Workflow

```fish
g       # git
gs      # git status
ga      # git add
gaa     # git add .
gc      # git commit
gcm     # git commit -m
gp      # git push
gpl     # git pull
gco     # git checkout
gcb     # git checkout -b
```

### Development

```fish
# Node.js with pnpm
npm     # pnpm (aliased)
ni      # pnpm install
nr      # pnpm run
ns      # pnpm start
nd      # pnpm dev

# Go development
gor     # go run
gob     # go build
got     # go test
gomt    # go mod tidy

# Docker
d       # docker
dc      # docker-compose
dcu     # docker-compose up
dcd     # docker-compose down

# Kubernetes
k       # kubectl
kgp     # kubectl get pods
kgs     # kubectl get services
```

### Conventional Commits

```fish
gfeat   # git commit -m "feat: "
gfix    # git commit -m "fix: "
gdocs   # git commit -m "docs: "
gchore  # git commit -m "chore: "
```

## 🔌 Installed Plugins

Essential plugins automatically installed via Fisher:

- **[jethrokuan/z](https://github.com/jethrokuan/z)** - Smart directory jumping (frecency-based)
- **[PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish)** - Fuzzy finder with beautiful interface
- **[franciscolourenco/done](https://github.com/franciscolourenco/done)** - Desktop notifications for long commands
- **[jorgebucaran/nvm.fish](https://github.com/jorgebucaran/nvm.fish)** - Fast Node.js version management
- **[joseluisq/gitnow](https://github.com/joseluisq/gitnow)** - Git workflow enhancements
- **[wfxr/forgit](https://github.com/wfxr/forgit)** - Interactive git operations
- **[jorgebucaran/autopair.fish](https://github.com/jorgebucaran/autopair.fish)** - Smart bracket completion

[See complete plugin list](common/fish/fish_plugins)

## ⚙️ Post-Installation Setup

### 1. Restart Your Terminal

Your new Fish shell will load automatically with all configurations.

### 2. Configure Development Environments

#### Node.js Setup

```fish
nvm install lts    # Install latest LTS
nvm use lts        # Use LTS version
# Global packages are already installed: pnpm, typescript, etc.
```

#### Python Setup

```fish
pyenv install 3.12.0    # Install Python 3.12
pyenv global 3.12.0     # Set as global version
# Common packages already installed: poetry, black, isort, etc.
```

#### Go Setup

```fish
go version    # Verify Go installation
golangci-lint --version    # Verify linter installation
# Go tools already installed: gopls, golangci-lint v2, air
```

### 3. Customize Your Setup (Optional)

#### Try Different Starship Presets

```fish
starship preset pure-preset -o ~/.config/starship.toml
starship preset gruvbox-rainbow -o ~/.config/starship.toml
# Restart terminal to see changes
```

#### Open Fish Web Configuration

```fish
fish_config    # Opens beautiful web UI in browser
```

## 🔍 Go Development with golangci-lint v2

This setup includes a comprehensive [.golangci.yml](common/go/.golangci.yml) configuration for Go projects:

### Key Features

- **50+ linters enabled** - Comprehensive code quality checks
- **Performance optimized** - Smart exclusions and settings
- **Modern Go practices** - Updated for Go 1.22+
- **Conventional formatting** - goimports, golines integration
- **Security focused** - gosec, errcheck, and more

### Usage

```fish
# In any Go project directory
golangci-lint run

# With auto-fix
golangci-lint run --fix

# Check specific files
golangci-lint run ./path/to/file.go
```

## 🎨 Customization

### Personal Overrides

Create these files for your customizations:

```fish
# ~/.config/fish/local.fish - Personal settings
abbr -a myproject 'cd ~/developer/myproject'
set -gx CUSTOM_VAR "my value"

# ~/.config/fish/work.fish - Work-specific settings
set -gx AWS_PROFILE work
abbr -a deploy './scripts/deploy.sh'

# ~/.config/fish/(hostname).fish - Machine-specific
set -gx DISPLAY_SCALE 2.0
```

### Adding Custom Functions

```fish
# ~/.config/fish/functions/myfunction.fish
function myfunction
    echo "Hello from Fish function!"
    # Your logic here
end
```

### Installing Additional Plugins

```fish
fisher install owner/plugin-name    # Install plugin
fisher remove owner/plugin-name     # Remove plugin
fisher list                         # List installed plugins
```

## 🔄 Maintenance

### Update Everything

```fish
update-all    # Updates Homebrew, npm, pip, gems, Fish plugins (+ apt on WSL)
```

### Individual Updates

```fish
brew update && brew upgrade    # Update Homebrew packages
fisher update                  # Update Fish plugins
nvm install lts               # Update to latest Node.js LTS
pyenv install 3.12.1          # Install newer Python version
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest  # Update golangci-lint
```

### Keep Dotfiles Updated

```fish
cd ~/.dotfiles
git pull origin main
./install.sh    # Re-run installer if needed
```

## 🐟 Fish Advantages Over Zsh

### Performance

- **68x faster startup** (47ms vs 3.2s for Zsh + Oh My Zsh)
- **Instant responsiveness** - no waiting for prompts
- **Efficient memory usage** - minimal resource consumption

### Intelligence

- **Smart autosuggestions** - based on history and context
- **Syntax highlighting** - real-time command validation
- **Superior tab completions** - works with Git, Docker, kubectl out-of-the-box
- **Command history** - powerful, searchable, shared across sessions

### Modern Features

- **Abbreviations** - expand as you type, better than aliases
- **Universal variables** - persist across sessions automatically
- **Web configuration** - `fish_config` opens beautiful GUI
- **Readable scripting** - much clearer than bash/zsh syntax

## 🎓 Learning Fish

### Essential Commands

```fish
# History
history                    # Show command history
history search term        # Search history

# Variables
set -g VAR value          # Global variable
set -U VAR value          # Universal variable (persistent)
set -e VAR                # Erase variable

# Functions
functions                 # List all functions
functions function_name   # Show function definition

# Abbreviations
abbr -l                   # List abbreviations
abbr -a name expansion    # Add abbreviation
abbr -e name              # Erase abbreviation
```

### Key Differences from Bash/Zsh

```fish
# Variables (no $ needed in assignments)
set name "Atakan"         # Not: name="Atakan"
echo $name                # Still use $ for expansion

# Arrays
set list a b c            # Create array
echo $list[1]             # Access first element (1-indexed!)

# Conditionals
if test $status -eq 0     # Much clearer than bash
    echo "Success"
end

# Loops
for item in $list
    echo $item
end
```

## 📚 Useful Resources

- **[Fish Documentation](https://fishshell.com/docs/current/)** - Official docs
- **[Fish Tutorial](https://fishshell.com/docs/current/tutorial.html)** - Interactive tutorial
- **[Awesome Fish](https://github.com/jorgebucaran/awsm.fish)** - Plugin collection
- **[golangci-lint Documentation](https://golangci-lint.run/)** - Go linter docs
- **[Fish vs Zsh vs Bash](https://github.com/fish-shell/fish-shell/wiki/Fish-vs.-zsh-vs.-bash-differences)** - Comparison guide

## 🚨 Troubleshooting

### Common Issues

#### Fish not default shell

If your terminal is still using zsh after installation:

```bash
# Check current shell
echo $SHELL

# If it's not fish, run these commands:
echo $(which fish) | sudo tee -a /etc/shells  # Add fish to shells
chsh -s $(which fish)                         # Set as default
exec fish                                     # Switch immediately
```

#### exa command not found

The modern replacement `eza` should be used instead of `exa`:

```bash
# Ensure eza is installed
brew install eza

# Check if your fish config uses eza (should show eza, not exa)
grep "abbr.*ls\|abbr.*ll" ~/.config/fish/config.fish

# If you see exa instead of eza, re-run the install script:
curl -fsSL https://raw.githubusercontent.com/atakanzen/dotfiles/main/install.sh | bash
```

#### Slow performance

```fish
time fish -c exit         # Profile startup time
fish --profile fish_profile.log -c exit    # Detailed profiling
```

#### Plugin issues

```fish
fisher list               # Check installed plugins
fisher update             # Update all plugins / sync with fish_plugins
```

> `fish_plugins` must contain one plugin per line with **no comments**. Fisher ignores any line containing whitespace, and it deletes the file when no plugins are left, so never use inline `# comments` there.

#### Path issues

```fish
echo $PATH                # Check current PATH
fish_add_path /new/path   # Add to PATH permanently
```

#### Go linting issues

```fish
golangci-lint --version   # Check version
golangci-lint linters     # List available linters
golangci-lint run --help  # Show help
```

### Getting Help

```fish
help                      # Open Fish help in browser
man fish                  # Fish manual page
fish_config               # Web-based configuration
```

## 🤝 Contributing

Found an improvement or bug? Contributions are welcome!

1. **Fork** this repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** on a fresh macOS installation and/or WSL Ubuntu distro
4. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Contribution Guidelines

- Test all changes on a clean macOS installation and a fresh WSL Ubuntu distro (`wsl --install -d Ubuntu-24.04 --name dotfiles-test`)
- Update documentation for any new features
- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Ensure scripts are compatible with both Intel and Apple Silicon Macs
- Keep casks out of `common/Brewfile` and `wsl/Brewfile`

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[Fish Shell Team](https://github.com/fish-shell/fish-shell)** - For creating an amazing shell
- **[Jorge Bucaran](https://github.com/jorgebucaran/fisher)** - Fisher plugin manager and Fish ecosystem
- **[Starship Team](https://github.com/starship/starship)** - Beautiful, fast prompt
- **[Ghostty](https://mitchellh.com/ghostty)** - Modern terminal emulator
- **[Homebrew](https://brew.sh/)** - Package management for macOS and Linux
- **[Gökhan Arkan](https://github.com/gokhanarkan/dotfiles)** - Original dotfiles this setup is forked from
- **[golangci-lint](https://golangci-lint.run/)** - Fast Go linters runner
- **Fish community** - For incredible plugins and continuous innovation

---

**🐟 Welcome to the Fish shell! Enjoy the speed and intelligence! 🚀**

_"Fish is a smart and user-friendly command line shell that works great out of the box."_

**Questions?** [Open an issue](https://github.com/atakanzen/dotfiles/issues) • **Want to contribute?** [See contributing guidelines](#-contributing)

**Contact:** Atakan Zengin - [@atakanzen](https://github.com/atakanzen) - atakanzzengin@gmail.com
