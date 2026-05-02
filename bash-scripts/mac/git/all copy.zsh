# Git 
unalias g
function g {
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m[ $(git branch --show-current) ]\033[0m"
    echo ''
    git status --show-stash 
}

unalias gg
function gg {
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m[ $(git branch --show-current) ]\033[0m"
    echo ''
    git status --show-stash --verbose 
}

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

function push {
    echo -e "\033[1m\033[38;2;252;196;106m-- EYF --\033[0m"
    git push --verbose --progress
    echo ''
    echo -e "\033[1m\033[38;2;252;196;106m-- PARRAKAT --\033[0m"
    git push parrakat --verbose  --progress
    git_status
}

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

function log {
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset)%n  %s%n" \
        --date=format:"%d/%m/%Y %H:%M"
}

function b {
    if [ -z "$1" ]; then
        git branch -a
    else
        git checkout "$@"
    fi
}

# Auxiliary
function git_status {
    echo ''
    echo '----------------------------------------------------------'
    echo ''
    git status --show-stash 
}
