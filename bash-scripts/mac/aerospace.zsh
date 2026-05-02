# Aerospace workspace switcher
# Usage: ws <name-or-shortcut>
# Add to ~/.zshrc

_ws_shortcuts=(
    "claude:ai-claude"
    "gemini:ai-gemini"
    "gpt:ai-gpt"
    "zap:lucas-whatsapp"
    "gmail:lucas-gmail"
    "drive:lucas-drive"
    "r:lucas-r"
    "t:lucas-t"
    "termf:terminal-frontend"
    "claudef:terminal-claude-frontend"
    "termb:terminal-backend"
    "claudeb:terminal-claude-backend"
    "term:terminal-g"
    "pchat:parrakat-chat"
    "pmail:parrakat-gmail"
    "pdrive:parrakat-drive"
    "git:github"
    "pmeet:parrakat-meet"
    "you:youtube"
    "music:music"
    "figma:figma"
    "local:localhost"
    "stage:staging"
    "browser:browser"
    "lucas:lucas"
    "vf:vscode-frontend"
    "vb:vscode-backend"
    "rest:insomnia"
    "db:d-beaver"
    "config:vscode-config"
)

i() {
    local input="$1"
    local target=""

    if [[ -z "$input" ]]; then
        echo "Usage: i <workspace-name-or-shortcut>"
        return 1
    fi

    # Check if input matches a shortcut
    for pair in $_ws_shortcuts; do
        local short="${pair%%:*}"
        local full="${pair##*:}"
        if [[ "$input" == "$short" ]]; then
            target="$full"
            break
        fi
    done

    # If no shortcut matched, use input as-is (full name or single letter/number)
    if [[ -z "$target" ]]; then
        target="$input"
    fi

    aerospace workspace "$target" && osascript -e 'tell application "System Events" to keystroke space using command down'
}

# Autocomplete for i
_i_complete() {
    local shortcuts=()
    local fullnames=()

    for pair in $_ws_shortcuts; do
        shortcuts+=("${pair%%:*}")
        fullnames+=("${pair##*:}")
    done

    # Single letters and numbers
    local singles=(i o p 4 5 6 7 8 9 0)

    local all=($shortcuts $fullnames $singles)
    compadd -a all
}

compdef _i_complete i