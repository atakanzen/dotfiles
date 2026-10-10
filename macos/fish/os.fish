# macOS-specific Fish configuration
# ~/.config/fish/conf.d/os.fish (loaded before config.fish)
# Author: Atakan Zengin (@atakanzen)

# Homebrew (Apple Silicon first, Intel fallback)
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
end

set -gx BROWSER open

# Networking
abbr -a localip 'ipconfig getifaddr en0'
abbr -a flushdns 'sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
