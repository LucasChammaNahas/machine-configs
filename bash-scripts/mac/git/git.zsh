# -------------------------------------------------------------------------------------------------
# GIT STATUS
# -------------------------------------------------------------------------------------------------
unalias g
function g {
    if ! _is_git_repo; then
        echo "Not a git repository"
        return 1
    fi

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
    elif [[ "$1" == "-m" ]]; then
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
        git commit -m "$*"
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
        git commit -m "$*"
        _separator
        g
    fi
}

function uc {
    # mod
    git reset --soft HEAD~1
    g
}


# -------------------------------------------------------------------------------------------------
# GIT PULL
# -------------------------------------------------------------------------------------------------
function p {
    # mod
    git pull --verbose --stat
    gg
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

    if _is_eyf; then
        _push_eyf
    else
        git push --verbose --progress
    fi

    echo ''
    _separator
    gg
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

    git fetch \
        --verbose \
        --all \
        --progress
    gg
}

# Lucas Only
function ff {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/parrakat/eyf-dashboard-frontend fetch

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/parrakat/eyf-dashboard-backend fetch
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

    if [ -z "$1" ]; then
        echo "This function is too dangerous to allow no arguments. Please specify files to remove."

    elif [ "$1" = "-t" ]; then
        _color red "(git restore .) This will discard all unstaged changes, but keep staged ones"
        if _confirm; then
            git restore .
        fi

    elif [ "$1" = "-u" ]; then
        _color red "(git clean -fd) This will remove all untracked files and directories"
        if _confirm; then
            git clean -fd
        fi

    elif [ "$1" = "-a" ]; then
        _color red "(git restore . && git clean -fd) This will discard all unstaged changes and remove all untracked files and directories"
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

    _color red "Files to be removed:"
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
    _color red "This will nuke everything!"
    if _confirm; then
        # mod
        # qq
        git reset --hard HEAD
        git clean -fd
        _separator
        gg
    fi
}

# -------------------------------------------------------------------------------------------------
# GIT LOG
# -------------------------------------------------------------------------------------------------
function log {
    echo ''
    _color pink "Commit count: $(git rev-list --count HEAD)"
    echo ''
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"
}

function logg {
    echo ''
    _color pink "Commit count: $(git rev-list --count HEAD)"
    echo ''
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"\
        --name-status
}

# -------------------------------------------------------------------------------------------------
# GIT BRANCH
# -------------------------------------------------------------------------------------------------
function b {
    if [ $# -eq 0 ]; then
        echo ''
        git branch -a
        echo ''
    else
        # mod
        git switch "$@"
        g
    fi
}

function bdiff {
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage: bdiff <branch1> [branch2]"
        return 1
    fi

    local branch1="$1"
    local branch2="${2:-HEAD}"

    read left right < <(git rev-list --left-right --count "$branch1"..."$branch2")

    if [ "$left" -eq 0 ] && [ "$right" -eq 0 ]; then
        _color green "✓ $branch1 and $branch2 are in sync"
        echo ''
    elif [ "$left" -eq 0 ]; then
        _color orange "$branch1 is behind $branch2 by $right commit(s)"
        echo ''
    elif [ "$right" -eq 0 ]; then
        _color orange "$branch2 is behind $branch1 by $left commit(s)"
        echo ''
    else
        _color red "✗ branches have diverged"
        echo "  $branch1 is ahead by $left commit(s)"
        echo "  $branch2 is ahead by $left commit(s)"
        echo ''
    fi
}


# -------------------------------------------------------------------------------------------------
# GIT STASH
# -------------------------------------------------------------------------------------------------
function stash {
    # mod
    if [ -z "$1" ]; then
        git stash
    else
        git stash "$@"
    fi
    g
}

function pop {
    # mod
    git stash pop
    g
}