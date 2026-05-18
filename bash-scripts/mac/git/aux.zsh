# -------------------------------------------------------------------------------------------------
# AUXILIARY FUNCTIONS
# -------------------------------------------------------------------------------------------------
function _is_zsh {
    [[ -n "$ZSH_VERSION" ]]
}

function _confirm {
    if _is_zsh; then
        read "confirm?Are you sure? (y/n) [y] "
    else
        read -p "Are you sure? (y/n) [y] " confirm
    fi

    local confirm=${confirm:-y}

    [[ "$confirm" =~ ^[Yy]$ ]]
}

# -------------------------------------------------------------------------------------------------
# AUXILIARY FUNCTIONS
# -------------------------------------------------------------------------------------------------
function _label_to_index {
    local label=$1
    local idx
    if [[ ${#label} -eq 1 ]]; then
        idx=$(( $(printf '%d' "'$label") - 97 ))
    else
        local first=$(( $(printf '%d' "'${label:0:1}") - 97 ))
        local second=$(( $(printf '%d' "'${label:1:1}") - 97 ))
        idx=$(( 26 + first * 26 + second ))
    fi
    if _is_zsh; then
        idx=$((idx + 1))
    fi
    echo $idx
}

function _index_to_label {
    local i=$1
    if [[ $i -lt 26 ]]; then
        printf "\\$(printf '%03o' $((97 + i)))"
    else
        local first=$(( (i - 26) / 26 ))
        local second=$(( (i - 26) % 26 ))
        printf "\\$(printf '%03o' $((97 + first)))\\$(printf '%03o' $((97 + second)))"
    fi
}

function _run_command_on_files {
    local git_command="$1"
    shift 1

    if [[ $# -eq 0 ]]; then
        echo "Wrong use of _run_command_on_files: no file letters provided."
        return 1
    fi

    local all_git_status_files=()
    while IFS= read -r line; do
        local f="${line:3}"
        f="${f//\"/}"
        all_git_status_files+=("$f")
    done < <(git status --short)

    local selected_files=()
    for letter in "$@"; do
        local idx=$(_label_to_index "$letter")
        local file="${all_git_status_files[$idx]}"
        if [[ -z "$file" ]]; then
            continue
        fi
        selected_files+=(\"$file\")
    done

    eval $git_command ${selected_files[@]}
}

function _file_selector_log {
    if ! _has_log_output; then
        return
    fi

    echo ''
    _separator
    echo ''

    local -A counts=(
        [unstaged]=0
        [staged]=0
        [untracked]=0
    )
    local i=0
    while IFS= read -r line; do
        local index_status="${line:0:1}"
        local worktree_status="${line:1:1}"
        local file="${line:3}"
        file="${file//\"/}"
        local letter=$(_index_to_label $i)
        local git_status="${index_status}${worktree_status}"
        local code="  ($letter) [$git_status]  $file"

        # 1. Merge conflicts
        if [[ "$index_status" == "U" || "$worktree_status" == "U" || "$git_status" == "AA" || "$git_status" == "DD" ]]; then
            _color pink "$code"
            ((counts[conflict]++))

        # 2. Untracked
        elif [[ "$git_status" == "??" ]]; then
            _color blue "$code"
            ((counts[untracked]++))

        # 3. Both staged AND unstaged (show both letters)
        elif [[ "$index_status" =~ [MADRC] && "$worktree_status" =~ [MD] ]]; then
            _color light_yellow "$code"
            ((counts[staged]++))
            ((counts[unstaged]++))

        # 4. Staged only (show the index letter)
        elif [[ "$index_status" =~ [MADRC] ]]; then
            _color green "$code"
            ((counts[staged]++))

        # 5. Unstaged only (show the worktree letter)
        elif [[ "$worktree_status" =~ [MD] ]]; then
            _color red "$code"
            ((counts[unstaged]++))

        else
            _color white "$code"
        fi

        i=$((i + 1))
    done < <(git status --short -u)

    echo ''
    _separator
    _color magenta "   Working (${counts[unstaged]}) | Index (${counts[staged]}) | Untracked (${counts[untracked]}) | Total ($i)"
    echo ''
}


# -------------------------------------------------------------------------------------------------
# VISUAL HELPERS
# -------------------------------------------------------------------------------------------------
function _separator {
    _color magenta '----------------------------------------------------------'
}

function _show_branch {
    _color yellow "[ $(git branch --show-current) ]"
}

function _color {
    local color=$1
    shift
    local text="$*"
    case $color in
        black)        echo -e "\e[30m${text}\e[0m" ;;
        red)          echo -e "\e[31m${text}\e[0m" ;;
        green)        echo -e "\e[32m${text}\e[0m" ;;
        yellow)       echo -e "\e[33m${text}\e[0m" ;;
        blue)         echo -e "\e[34m${text}\e[0m" ;;
        magenta)      echo -e "\e[35m${text}\e[0m" ;;
        cyan)         echo -e "\e[36m${text}\e[0m" ;;
        white)        echo -e "\e[37m${text}\e[0m" ;;
        deep_blue)    echo -e "\e[38;5;63m${text}\e[0m" ;;
        deep_purple)  echo -e "\e[38;5;93m${text}\e[0m" ;;
        purple)       echo -e "\e[38;5;129m${text}\e[0m" ;;
        pink)         echo -e "\e[38;5;201m${text}\e[0m" ;;
        orange)       echo -e "\e[38;5;209m${text}\e[0m" ;;
        light_yellow) echo -e "\e[38;5;227m${text}\e[0m" ;;
        *)            echo -e "${text}" ;;
    esac
}

# -------------------------------------------------------------------------------------------------
# GIT CHECKS
# -------------------------------------------------------------------------------------------------
function _is_git_repo {
    git rev-parse --git-dir > /dev/null 2>&1
}

function _has_log_output {
    [[ $(git status --short | wc -l) -gt 0 ]]
}
