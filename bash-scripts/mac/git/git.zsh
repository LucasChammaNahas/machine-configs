# -------------------------------------------------------------------------------------------------
# GIT STATUS
# -------------------------------------------------------------------------------------------------
function _file_selector_log {
    if ! _has_log_output; then
        return
    fi

    echo ''
    _separator
    echo ''

    local i=0
    while IFS= read -r line; do
        local git_status="${line:0:2}"
        local file="${line:3}"
        file="${file//\"/}"
        local letter=$(_index_to_label $i)
        if [[ "$git_status" == "??" ]]; then
            echo -e "  \e[35m[$letter] $file\e[0m"
        elif [[ "${git_status:0:1}" =~ [MADRC] ]]; then
            echo -e "  \e[32m[$letter] $file\e[0m"
        elif [[ "${git_status:1:1}" =~ [MD] ]]; then
            echo -e "  \e[31m[$letter] $file\e[0m"
        fi
        i=$((i + 1))
    done < <(git status --short)

    echo ''
    _separator
    echo ''
}

unalias g
function g {
    if ! _is_git_repo; then
        echo "Not a git repository"
        return 1
    fi

    # mod
    # qq
    echo ''
    _show_branch
    echo ''
    git status | head -2
    echo ''
    _file_selector_log
}

unalias gg
function gg {
    if ! _is_git_repo; then
        echo "Not a git repository"
        return 1
    fi

    # mod
    # qq
    echo ''
    _show_branch
    echo ''
    git status --show-stash 
    echo ''
    _file_selector_log
}


# -------------------------------------------------------------------------------------------------
# GIT ADD
# -------------------------------------------------------------------------------------------------
function a {
    if [ -z "$1" ]; then
        git add .
    elif [[ "$1" == "-u" ]]; then
        git ls-files --others --exclude-standard | xargs git add
    elif [[ "$1" == "-t" ]]; then
        git add -u
    else
        _run_command_on_files "git add" "$@"
    fi
    g
}

function aa {
    git add "$@"
    g
}

function u {
    # mod
    # qq
    if [ -z "$1" ]; then
        git restore --staged .
    else
        _run_command_on_files "git restore --staged" "$@"
    fi
    g
}


# -------------------------------------------------------------------------------------------------
# GIT COMMIT
# -------------------------------------------------------------------------------------------------
function c {
    if [ -z "$1" ]; then
        git commit
    else
        git commit -m "$@"
    fi
    _separator
    g
}

function ac {
    if [ -z "$1" ]; then
        echo "Please provide a commit message."
        return 1
    else
        git add .
        git commit -m "$@"
        _separator
        g
    fi
}

function uc {
    # mod
    # qq
    git reset --soft HEAD~1
    g
}


# -------------------------------------------------------------------------------------------------
# GIT PULL
# -------------------------------------------------------------------------------------------------
function p {
    # mod
    # qq
    git pull --verbose --stat
    g
}

# Lucas Only
function pp {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/parrakat/eyf-dashboard-frontend pull

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/parrakat/eyf-dashboard-backend pull

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND MATHEUS --\033[0m"
    echo ''
    git -C ~/projects/parrakat/eyf-new-backend pull
}


# -------------------------------------------------------------------------------------------------
# GIT PUSH
# -------------------------------------------------------------------------------------------------
# Lucas 
function push {
    # mod
    # qq

    if _is_eyf; then
        _push_eyf
    else
        git push --verbose --progress
    fi

    echo ''
    _separator
    g
}

# Lucas Only
function _is_eyf {
    local eyf_dirs=(
        "$HOME/projects/parrakat/eyf-dashboard-backend"
        "$HOME/projects/parrakat/eyf-dashboard-frontend"
    )
    for dir in "${eyf_dirs[@]}"; do
        [[ "$PWD" == "$dir" ]] && return 0
    done
    return 1
}

# Lucas Only
function _push_eyf {
    echo -e "\033[1m\033[38;2;252;196;106m-- EYF --\033[0m"
    git push --verbose --progress
    _separator
    echo -e "\033[1m\033[38;2;252;196;106m-- PARRAKAT --\033[0m"
    git push parrakat --verbose --progress
}


# -------------------------------------------------------------------------------------------------
# GIT FETCH
# -------------------------------------------------------------------------------------------------
function f {
    # mod
    # qq
    git fetch \
        --verbose \
        --all \
        --progress
    g
}

# Lucas Only
function ff {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-frontend fetch

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-backend fetch
}


# -------------------------------------------------------------------------------------------------
# GIT DIFF
# -------------------------------------------------------------------------------------------------
function d {
    if [ -z "$1" ]; then
        git diff
    elif [[ "$1" == "-v" ]]; then
        git diff HEAD
    else
        _run_command_on_files "git diff HEAD" "$@"
    fi
}


# -------------------------------------------------------------------------------------------------
# GIT REMOVE
# -------------------------------------------------------------------------------------------------
function r {
    # mod
    # qq

    if [ -z "$1" ]; then
        echo "This function is too dangerous to allow no arguments. Please specify files to remove."

    elif [ "$1" = "-t" ]; then
        echo -e "\e[1;31m⚠️  git restore .\e[0m"
        if _confirm; then
            git restore .
        fi

    elif [ "$1" = "-u" ]; then
        echo -e "\e[1;31m⚠️  git clean -fd\e[0m"
        if _confirm; then
            git clean -fd
        fi

    elif [ "$1" = "-a" ]; then
        echo -e "\e[1;31m⚠️  git restore . && git clean -fd\e[0m"
        if _confirm; then
            git restore .
            git clean -fd
        fi

    else
        _run_command_on_files "_git_handle_removal" "$@"
    fi

    _separator
    g
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

function _git_handle_removal {
    if [[ $# -eq 0 ]]; then
        return 1
    fi

    echo -e "\e[1;31mFiles to be removed:\e[0m"
    for file_name in "$@"; do
        echo "  - $file_name"
    done
    echo ''

    if ! _confirm; then
        echo ''
        echo "Aborting removal."
        return 0
    fi
    
    for file_path in "$@"; do
        file_status=$(_get_file_status "$file_path")
        if [[ "$file_status" == *"unstaged"* ]]; then
            git restore "$file_path"
        elif [[ "$file_status" == "untracked" ]]; then
            rm -rf "$file_path"
        else
            echo "Action not possible for file with status: $file_status"
        fi
    done
}

function nuke {
    echo -e "\e[1;31m⚠️  This will destroy all changes!\e[0m"
    if _confirm; then
        # mod
        # qq
        git reset --hard HEAD
        git clean -fd
        _separator
        g
    fi
}

# -------------------------------------------------------------------------------------------------
# GIT LOG
# -------------------------------------------------------------------------------------------------
function log {
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"
}

function logg {
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"\
        --name-status
}


# -------------------------------------------------------------------------------------------------
# GIT BRANCH
# -------------------------------------------------------------------------------------------------
function b {
    # mod
    # qq
    if [ -z "$1" ]; then
        git branch -a
    else
        git checkout "$@"
    fi
}


# -------------------------------------------------------------------------------------------------
# GIT STASH
# -------------------------------------------------------------------------------------------------
function stash {
    # mod
    # qq
    if [ -z "$1" ]; then
        git stash -U
    else
        git stash "$@"
    fi
    g
}