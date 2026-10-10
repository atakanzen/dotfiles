# Fish Shell Configuration
# ~/.config/fish/config.fish
# Modern, blazing-fast shell setup optimized for development
# Author: Atakan Zengin (@atakanzen)
# OS-specific settings live in ~/.config/fish/conf.d/os.fish (macos/ or wsl/ in the repo)

# Disable fish greeting
set -g fish_greeting

# ===== ENVIRONMENT VARIABLES =====

# Core settings
set -gx EDITOR code
set -gx VISUAL code
set -gx TERM xterm-256color

# Language settings
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# ===== PATH CONFIGURATION =====

# Essential paths
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin

# Go configuration
set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin
fish_add_path $GOBIN

# ===== DEVELOPMENT ENVIRONMENT SETUP =====

# Homebrew is initialised in conf.d/os.fish (path differs per OS)

# Node.js (nvm.fish plugin handles this automatically)
# Python (pyenv)
if command -q pyenv
    set -gx PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - | source
end

# Ruby (rbenv)
if command -q rbenv
    rbenv init - | source
end

# Docker configuration
set -gx DOCKER_BUILDKIT 1
set -gx COMPOSE_DOCKER_CLI_BUILD 1

# ===== ABBREVIATIONS =====
# Fish abbreviations expand when you press space - much better than aliases!

# System utilities
abbr -a ll 'eza -la --git --icons'
abbr -a la 'eza -la --git --icons'
abbr -a ls 'eza --icons'
abbr -a l 'eza -l --git --icons'
abbr -a tree 'eza --tree --icons'
abbr -a cat 'bat'
abbr -a grep 'rg'
abbr -a find 'fd'

# Editor (Neovim as the default vim)
abbr -a vim 'nvim'
abbr -a vi 'nvim'

# Directory navigation
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a ~ 'cd ~'

# Git workflow (essential for productivity)
abbr -a g 'git'
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gaa 'git add .'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gca 'git commit --amend'
abbr -a gcan 'git commit --amend --no-edit'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a gf 'git fetch'
abbr -a gb 'git branch'
abbr -a gba 'git branch -a'
abbr -a gbd 'git branch -d'
abbr -a gbD 'git branch -D'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gm 'git merge'
abbr -a gr 'git rebase'
abbr -a gri 'git rebase -i'
abbr -a gst 'git stash'
abbr -a gstp 'git stash pop'
abbr -a gsta 'git stash apply'
abbr -a gd 'git diff'
abbr -a gdc 'git diff --cached'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a gla 'git log --oneline --graph --decorate --all'
abbr -a glog 'git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Advanced Git workflows
abbr -a gwip 'git add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
abbr -a gunwip 'git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
abbr -a gclean 'git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d'
abbr -a gpush 'git push origin (git branch --show-current)'
abbr -a gpull 'git pull origin (git branch --show-current)'

# Conventional commits (modern development practice)
abbr -a gfeat 'git commit -m "feat: "'
abbr -a gfix 'git commit -m "fix: "'
abbr -a gdocs 'git commit -m "docs: "'
abbr -a gstyle 'git commit -m "style: "'
abbr -a grefactor 'git commit -m "refactor: "'
abbr -a gtest 'git commit -m "test: "'
abbr -a gchore 'git commit -m "chore: "'

# Docker shortcuts
abbr -a d 'docker'
abbr -a dc 'docker-compose'
abbr -a dcu 'docker-compose up'
abbr -a dcd 'docker-compose down'
abbr -a dcb 'docker-compose build'
abbr -a dcl 'docker-compose logs'
abbr -a dps 'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a di 'docker images'
abbr -a drm 'docker rm'
abbr -a drmi 'docker rmi'
abbr -a dprune 'docker system prune -af'

# Node.js/pnpm (preferred over npm)
abbr -a npm 'pnpm'
abbr -a npx 'pnpx'
abbr -a ni 'pnpm install'
abbr -a na 'pnpm add'
abbr -a nad 'pnpm add -D'
abbr -a nr 'pnpm run'
abbr -a ns 'pnpm start'
abbr -a nt 'pnpm test'
abbr -a nb 'pnpm build'
abbr -a nd 'pnpm dev'

# Go development
abbr -a gor 'go run'
abbr -a gob 'go build'
abbr -a got 'go test'
abbr -a goi 'go install'
abbr -a gom 'go mod'
abbr -a gomt 'go mod tidy'
abbr -a air 'air' # Live reload for Go
abbr -a golint 'golangci-lint run'
abbr -a golintfix 'golangci-lint run --fix'

# Python development
abbr -a py 'python3'
abbr -a pip 'pip3'
abbr -a venv 'python3 -m venv'
abbr -a activate 'source venv/bin/activate'

# Kubernetes
abbr -a k 'kubectl'
abbr -a kgp 'kubectl get pods'
abbr -a kgs 'kubectl get services'
abbr -a kgd 'kubectl get deployments'
abbr -a kaf 'kubectl apply -f'
abbr -a kdel 'kubectl delete'
abbr -a klogs 'kubectl logs'
abbr -a kexec 'kubectl exec -it'

# System utilities
abbr -a myip 'curl -s https://httpbin.org/ip | jq -r .origin'
abbr -a ports 'lsof -i -P -n | grep LISTEN'
abbr -a cleanup 'brew cleanup && docker system prune -af'

# Quick config edits
abbr -a fishconfig 'code ~/.config/fish/config.fish'
abbr -a starshipconfig 'code ~/.config/starship.toml'
abbr -a gitconfig 'code ~/.gitconfig'

# ===== FUNCTIONS =====

# Create directory and enter it
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Extract any archive format
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar e $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Find and kill process by name
function killp
    ps aux | grep $argv[1] | grep -v grep | awk '{print $2}' | xargs kill -9
end

# Quick HTTP server
function serve
    set port $argv[1]
    if test -z "$port"
        set port 8000
    end
    python3 -m http.server $port
end

# Quick note taking
function note
    set note_file "$HOME/notes/"(date +%Y-%m-%d)".md"
    mkdir -p (dirname "$note_file")
    echo "# "(date +%Y-%m-%d) >> "$note_file"
    echo "" >> "$note_file"
    echo $argv >> "$note_file"
    echo "" >> "$note_file"
    echo "Note added to $note_file"
end

# Docker cleanup
function docker-cleanup
    echo "🧹 Cleaning up Docker resources..."
    docker system prune -af
    docker volume prune -f
    docker network prune -f
    echo "✅ Docker cleanup completed"
end

# Update all package managers
function update-all
    echo "🔄 Starting comprehensive update..."

    echo "🍺 Updating Homebrew..."
    brew update && brew upgrade

    echo "📦 Updating global packages..."
    if command -q pnpm
        pnpm update -g
    end

    echo "🐍 Updating Python packages..."
    if command -q pip3
        pip3 list --outdated --format=json | jq -r '.[] | .name' | xargs -n1 pip3 install --upgrade
    end

    echo "💎 Updating Ruby gems..."
    if command -q gem
        gem update
    end

    # OS-specific updates (e.g. apt on WSL), defined in conf.d/os.fish
    if functions -q __os_update
        __os_update
    end

    echo "🎣 Updating Fish plugins..."
    fisher update

    echo "✨ All package managers updated!"
end

# Git conventional commit helper
function gconv
    if test (count $argv) -lt 2
        echo "Usage: gconv <type> <message>"
        echo "Types: feat, fix, docs, style, refactor, test, chore"
        return 1
    end
    git commit -m "$argv[1]: $argv[2..-1]"
end

# Create new Git branch with automatic push setup
function gnb
    if test (count $argv) -lt 1
        echo "Usage: gnb <branch-name>"
        return 1
    end
    git checkout -b $argv[1]
    git push -u origin $argv[1]
end

# Project initialization shortcuts
function init-go
    if test (count $argv) -lt 1
        echo "Usage: init-go <module-name>"
        return 1
    end
    go mod init $argv[1]
    echo "package main\n\nimport \"fmt\"\n\nfunc main() {\n\tfmt.Println(\"Hello, World!\")\n}" > main.go
    echo "✅ Go project initialized"
end

function init-node
    if test (count $argv) -lt 1
        echo "Usage: init-node <project-name>"
        return 1
    end
    pnpm init
    pnpm add -D typescript @types/node prettier eslint
    echo "✅ Node.js project initialized with TypeScript"
end

function init-python
    if test (count $argv) -lt 1
        echo "Usage: init-python <project-name>"
        return 1
    end
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    echo "✅ Python project initialized with virtual environment"
end

# ===== TOOL INTEGRATIONS =====

# Zoxide (smart cd replacement) - installed via z plugin
if command -q zoxide
    zoxide init fish | source
    abbr -a cd 'z'
end

# Direnv (automatic environment loading)
if command -q direnv
    direnv hook fish | source
end

# FZF integration (handled by fzf.fish plugin)
if command -q fzf
    set -gx FZF_DEFAULT_OPTS "
        --height 60%
        --layout=reverse
        --border=rounded
        --preview 'bat --style=numbers --color=always --line-range :500 {}'
        --preview-window right:50%:wrap
        --color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    "

    if command -q rg
        set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    end
end

# GitHub CLI completions
if command -q gh
    gh completion -s fish | source
end

# ===== STARSHIP PROMPT =====
if command -q starship
    starship init fish | source
end

# ===== PERFORMANCE OPTIMIZATIONS =====
set -g fish_history_max 10000

# ===== LOAD LOCAL CONFIGURATIONS =====
if test -f ~/.config/fish/work.fish
    source ~/.config/fish/work.fish
end

if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

if test -f ~/.config/fish/(hostname).fish
    source ~/.config/fish/(hostname).fish
end

# ===== WELCOME MESSAGE =====
if status is-interactive
    echo "🐟 Fish shell loaded successfully!"
    echo "💡 Pro tip: Type 'abbr -l' to see all abbreviations"
    echo "🔧 Run 'fish_config' to open web configuration"
end
