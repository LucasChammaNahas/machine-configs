# -------------------------------------------------------------------------------------------------
# AUXILIARY FUNCTIONS
# ------------------------------------------------------------------------------------------------
function _is_zsh {
    [[ -n "$ZSH_VERSION" ]]
}

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


# -------------------------------------------------------------------------------------------------
# VISUAL HELPERS
# ------------------------------------------------------------------------------------------------
function _separator {
    echo '----------------------------------------------------------'
}

function _show_branch {
    echo -e "\e[1;33m[ $(git branch --show-current) ]\e[0m"
}


# -------------------------------------------------------------------------------------------------
# GIT CHECKS
# ------------------------------------------------------------------------------------------------
function _is_git_repo {
    git rev-parse --git-dir > /dev/null 2>&1
}

function _has_log_output {
    [[ $(git status --short | wc -l) -gt 0 ]]
}
