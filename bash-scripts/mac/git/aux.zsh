# -------------------------------------------------------------------------------------------------
# AUXILIARY FUNCTIONS
# ------------------------------------------------------------------------------------------------
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
        local idx=$(( $(printf '%d' "'$letter") - 96 ))
        local file="${all_git_status_files[$idx]}"
        if [[ -z "$file" ]]; then
            continue
        fi
        selected_files+=(\"$file\")
    done
    
    eval $git_command ${selected_files[@]}
}

function _get_file_status {
    # get the two-char porcelain status for this exact file
    local git_status=$(git status --porcelain "$1" | cut -c1-2)
    local staged="${git_status:0:1}"
    local unstaged="${git_status:1:1}"
    
    local states=()
    [[ "$git_status" == "??" ]] && states+=("untracked")
    [[ "$staged" =~ [MADRC] ]] && states+=("staged")
    [[ "$unstaged" =~ [MD] ]] && states+=("unstaged")
    [[ "$staged" == "U" || "$unstaged" == "U" ]] && states+=("conflicted")
    
    echo "${states[@]}"
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
