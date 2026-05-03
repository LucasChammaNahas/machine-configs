# -------------------------------------------------------------------------------------------------
# GIT STATUS
# ------------------------------------------------------------------------------------------------
unalias g
function g {
    if ! is_git_repo; then
        echo "Not a git repository"
        return 1
    fi
    _show_branch
    
    local files=()
    while IFS= read -r line; do
        local f="${line:3}"
        f="${f//\"/}"
        files+=("$f")
    done < <(git status --short)
    
    local status_output
    status_output=$(git -c color.status=always status --show-stash)
    
    local ESC=$'\x1b'
    local i=0
    for file in "${files[@]}"; do
        local letter=$(printf "\\$(printf '%03o' $((97 + i)))")
        status_output=$(echo "$status_output" | sed -E "s|^([[:space:]]*)($ESC\[[0-9;]*m)?(modified:[[:space:]]+)?($file)|\1\2[$letter] \4|")
        i=$((i + 1))
    done
    
    echo "$status_output" \
        | grep -v '^\s*(use ' \
        | grep -v '^no changes added to commit' \
        | grep -v '^Changes to be committed:' \
        | grep -v '^Changes not staged for commit:' \
        | grep -v '^Untracked files:' \
        | grep -v '^On branch' \
        | grep -v '^Your branch' \
        | grep -v '^nothing to commit' \
}

unalias gg
function gg {
    _show_branch
    git status --show-stash "$@" 
}


# -------------------------------------------------------------------------------------------------
# GIT ADD
# ------------------------------------------------------------------------------------------------
function a {
    if [ -z "$1" ]; then
        git add .
    elif [[ "$1" == "-u" ]]; then
        git ls-files --others --exclude-standard | xargs git add
    elif [[ "$1" == "-t" ]]; then
        git add -u
    else
        _git_run_on_files "git add" "" "$@"
    fi
    g
}

function u {
    if [ -z "$1" ]; then
        git restore --staged .
    else
        _git_run_on_files "git restore --staged" "" "$@"
    fi
    g
}


# -------------------------------------------------------------------------------------------------
# GIT COMMIT
# ------------------------------------------------------------------------------------------------
function c {
    if [ -z "$1" ]; then
        git commit
    else
        git commit -m "$@"
    fi
    g
}

function ac {
    if [ -z "$1" ]; then
        echo "Please provide a commit message."
        return 1
    else
        git add .
        git commit -m "$@"
        g
    fi
}

function uc {
    git reset --soft HEAD~1
    g
}


# -------------------------------------------------------------------------------------------------
# GIT PULL
# ------------------------------------------------------------------------------------------------
function p {
    git pull --verbose --stat
    g
}

function pp {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-frontend pull

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-backend pull

    _separator

    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND MATHEUS --\033[0m"
    echo ''
    git -C ~/projects/eyf-new-backend pull
}


# -------------------------------------------------------------------------------------------------
# GIT PUSH
# ------------------------------------------------------------------------------------------------
function push {
    if _is_eyf; then
        _push_eyf
    else
        git push --verbose --progress
    fi
    g
}

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

function _push_eyf {
    echo -e "\033[1m\033[38;2;252;196;106m-- EYF --\033[0m"
    git push --verbose --progress
    _separator
    echo -e "\033[1m\033[38;2;252;196;106m-- PARRAKAT --\033[0m"
    git push parrakat --verbose --progress
}


# -------------------------------------------------------------------------------------------------
# GIT FETCH
# ------------------------------------------------------------------------------------------------
function f {
    git fetch \
        --verbose \
        --all \
        --progress
    g
}

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
# ------------------------------------------------------------------------------------------------
function d {
    if [ -z "$1" ]; then
        git diff
    elif [[ "$1" == "-v" ]]; then
        git diff HEAD
    else
        _git_run_on_files "git diff HEAD" "" "$@"
    fi
    
    g
}


# -------------------------------------------------------------------------------------------------
# GIT REMOVE
# ------------------------------------------------------------------------------------------------
function r {
    if [ -z "$1" ]; then
        echo "This function is too dangerous to allow no arguments. Please specify files to remove."

    elif [ "$1" = "-t" ]; then
        echo -e "\e[1;31m⚠️  git restore .\e[0m"
        read "confirm?Are you sure? (y/n) [y] "
        local confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git restore .
        fi
        
    elif [ "$1" = "-u" ]; then
        echo -e "\e[1;31m⚠️  git clean -fd\e[0m"
        read "confirm?Are you sure? (y/n) [y] "
        local confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git clean -fd
        fi

    elif [ "$1" = "-a" ]; then
        echo -e "\e[1;31m⚠️  git restore . && git clean -fd\e[0m"
        read "confirm?Are you sure? (y/n) [y] "
        local confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git restore .
            git clean -fd
        fi

    else
        _git_run_on_files "_git_handle_removal" "" "$@"
    fi

    _separator
    g
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

    read "confirm?Are you sure? (y/n) [y] "
    local confirm=${confirm:-y}
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
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

    read "confirm?Are you sure? (y/n) [y] "
    local confirm=${confirm:-y}
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git reset --hard HEAD
        git clean -fd
        echo "All changes nuked"
        _separator
        g
    fi
}

# -------------------------------------------------------------------------------------------------
# GIT LOG
# ------------------------------------------------------------------------------------------------
function log {
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"
}


# -------------------------------------------------------------------------------------------------
# GIT BRANCH
# ------------------------------------------------------------------------------------------------
function b {
    if [ -z "$1" ]; then
        git branch -a
    else
        git checkout "$@"
    fi
}


# -------------------------------------------------------------------------------------------------
# GIT STASH
# ------------------------------------------------------------------------------------------------
function stash {
    if [ -z "$1" ]; then
        git stash -U
    else
        git stash "$@"
    fi
    g
}