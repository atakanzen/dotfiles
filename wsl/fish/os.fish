# WSL Ubuntu-specific Fish configuration
# ~/.config/fish/conf.d/os.fish (loaded before config.fish)
# Author: Atakan Zengin (@atakanzen)

# Homebrew on Linux
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# Open files/URLs with the Windows default app (wslview comes from the wslu apt package)
if command -q wslview
    set -gx BROWSER wslview
    abbr -a open 'wslview'
end

# Windows home directory, e.g. /mnt/c/Users/<you>
# Resolved once and cached as a universal variable (calling cmd.exe on every startup is slow)
if not set -q WINHOME; and command -q cmd.exe
    set -l win_user (cmd.exe /c 'echo %USERNAME%' 2>/dev/null | string trim)
    if test -n "$win_user"; and test -d /mnt/c/Users/$win_user
        set -Ux WINHOME /mnt/c/Users/$win_user
    end
end
if set -q WINHOME
    abbr -a winhome 'cd $WINHOME'
end

# macOS-style clipboard commands backed by the Windows clipboard
function pbcopy --description 'Copy stdin to the Windows clipboard'
    clip.exe
end

function pbpaste --description 'Print the Windows clipboard'
    powershell.exe -NoProfile -Command Get-Clipboard | string replace -r '\r$' ''
end

# Networking
abbr -a localip 'hostname -I | awk \'{print $1}\''

# Called by update-all (config.fish)
function __os_update
    echo "🐧 Updating apt packages..."
    sudo apt update && sudo apt upgrade -y
end
