# -------------------------------------------------------------------------------------------------
# GIT STATUS
# ------------------------------------------------------------------------------------------------
unalias g
function g {
    if is_git_repo; then
        _show_branch
        
        local files=()
        while IFS= read -r line; do
            local f="${line:3}"
            f="${f//\"/}"  # strip quotes
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
            | sed -E "s|^(Changes to be committed:)|$(printf '\033[32m')\1$(printf '\033[m')|" \
            | sed -E "s|^(Changes not staged for commit:)|$(printf '\033[31m')\1$(printf '\033[m')|" \
            | sed -E "s|^(Untracked files:)|$(printf '\033[33m')\1$(printf '\033[m')|"
    fi
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
    else
        git add "$@"
    fi
    git_status
}

function ua {
    if [ -z "$1" ]; then
        git restore --staged .
    else
        git restore --staged "$@"
    fi
    git_status
}


# -------------------------------------------------------------------------------------------------
# GIT COMMIT
# ------------------------------------------------------------------------------------------------
function c {
    if [ -z "$1" ]; then
        echo "Please provide a commit message."
        return 1
    else
        git commit -m "$@"
        git_status
    fi
}

function ac {
    if [ -z "$1" ]; then
        echo "Please provide a commit message."
        return 1
    else
        git add .
        git commit -m "$@"
        git_status
    fi
}

function uc {
    git reset --soft HEAD~1
    git_status
}


# -------------------------------------------------------------------------------------------------
# GIT PULL
# ------------------------------------------------------------------------------------------------
function p {
    git pull \
        --verbose \
        --stat \
        --log \
        --compact-summary
    git_status
}

function pp {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-frontend pull

    echo ''
    echo ''
    echo '----------------------------------------------------------'
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-backend pull

    echo ''
    echo ''
    echo '----------------------------------------------------------'
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND MATHEUS --\033[0m"
    echo ''
    git -C ~/projects/eyf-new-backend pull
}


# -------------------------------------------------------------------------------------------------
# GIT PUSH
# ------------------------------------------------------------------------------------------------
function push {
    echo -e "\033[1m\033[38;2;252;196;106m-- EYF --\033[0m"
    git push --verbose --progress
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m-- PARRAKAT --\033[0m"
    git push parrakat --verbose  --progress
    git_status
}


# -------------------------------------------------------------------------------------------------
# GIT FETCH
# ------------------------------------------------------------------------------------------------
function f {
    git fetch \
        --verbose \
        --all \
        --progress
    git_status
}

function ff {
    echo -e "\033[1m\033[38;2;252;196;106m-- FRONTEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-frontend fetch
    echo ''
    echo ''
    echo '----------------------------------------------------------'
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m-- BACKEND --\033[0m"
    echo ''
    git -C ~/projects/eyf-dashboard-backend fetch
}


# -------------------------------------------------------------------------------------------------
# GIT DIFF
# ------------------------------------------------------------------------------------------------
function d {
    if [ -z "$1" ]; then
        git diff --color-words
    else
        git diff --color-words "$@"
    fi
}

function dd {
    if [ -z "$1" ]; then
        git diff HEAD --color-words
    else
        git diff HEAD --color-words "$@"
    fi
}

function nuke {
    echo -e "\033[1;31m⚠️  This will destroy all tracked changes!\033[0m"
    read "confirm?Are you sure? (y/n) "
    if [ "$confirm" = "y" ]; then
        git reset --hard HEAD
        git clean -fd
        echo "All tracked changes nuked"
        git_status
    else
        echo "Aborted"
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
