function g {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "\e[1;33m[ $(git branch --show-current) ]\e[0m"
        echo ""
        git status --show-stash
        echo ""
        qq
    fi
}

function gg {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "\e[1;33m[ $(git branch --show-current) ]\e[0m"
        echo ""
        git status --show-stash --verbose 
        _separator
        qq
    fi
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
        git commit
        git_status 
        return 1
    fi
    git commit -m "$@"
    git_status 
}

function ac {
    if [ -z "$1" ]; then
        echo "Please provide a commit message"
        return 1
    fi
    git add .
    git commit -m "$@"
    git_status 
}

function uc {
    git reset --soft HEAD~1
    git_status 
}

function d {
    if [ "$1" = "-a" ]; then
        git diff HEAD --color-words

    elif [ -n "$1" ]; then
        git diff --color-words "$@"

    else
        git_status

        files=($(git status --short | grep -v '^??' | awk '{print $2}'))
        if [ ${#files[@]} -eq 0 ]; then
            echo "No changed files"
            return
        fi

        letters=({a..z})
        for i in "${!files[@]}"; do
            echo "${letters[$i]}. ${files[$i]}"
        done

        read -p "Pick a file: " choice
        for i in "${!letters[@]}"; do
            if [ "${letters[$i]}" = "$choice" ]; then
                git diff --color-words "${files[$i]}" 
                break
            fi
        done
    fi
}

function dd {
    if [ "$1" = "-a" ]; then
        git diff HEAD --color-words
    else
        git diff --color-words
    fi
}

function p {
    mod
    git pull \
        --verbose \
        --stat \
        --log
    git_status
}

function push {
    git push \
        --verbose \
        --progress
    git_status
}

function f {
    git fetch \
        --verbose \
        --all \
        --progress
    git_status
}

function log {
    git log \
        --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(magenta)%ad%C(reset) %C(red)%D%C(reset)%n  %s%n" \
        --date=iso
}

function r {
    if [ -z "$1" ]; then
        git_status

        files=($(git status --short | awk '{print $2}'))
        if [ ${#files[@]} -eq 0 ]; then
            echo "No changed files"
            return
        fi

        letters=({a..z})
        for i in "${!files[@]}"; do
            echo "${letters[$i]}. ${files[$i]}"
        done
        
        read -p "Pick a file: " choice
        for i in "${!letters[@]}"; do
            if [ "${letters[$i]}" = "$choice" ]; then
                _r "${files[$i]}"
                break
            fi
        done

    elif [ "$1" = "-t" ]; then
        echo -e "\e[1;31m⚠️  git restore .\e[0m"
        read -p "Are you sure? (y/n) [y] " confirm
        confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git restore .
        fi

    elif [ "$1" = "-u" ]; then
        echo -e "\e[1;31m⚠️  git clean -fd\e[0m"
        read -p "Are you sure? (y/n) [y] " confirm
        confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git clean -fd
        fi

    elif [ "$1" = "-a" ]; then
        echo -e "\e[1;31m⚠️  git restore . && git clean -fd\e[0m"
        read -p "Are you sure? (y/n) [y] " confirm
        confirm=${confirm:-y}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git restore .
            git clean -fd
        fi

    else
        for file in "$@"; do
            _r "$file"
        done
    fi
    git_status
}

function nuke {
    echo -e "\e[1;31m⚠️  This will destroy all changes!\e[0m"
    echo "\nThis will be removed:"
    git status
    git clean -nd
    read -p "Are you sure? (y/n) " confirm
    if [ "$confirm" = "y" ]; then
        git reset --hard HEAD
        git clean -fd
        echo "All changes nuked"
        git_status
    else
        echo "Aborted"
    fi
}

function b {
    if [ -z "$1" ]; then
        git branch -a
    else
        git checkout "$@"
    fi
    git_status
}

function stash {
    mod
    if [ -z "$1" ]; then
        git stash -U
    else
        git stash "$@"
    fi
    git_status
}


# Auxiliary

function git_status {
    _separator
    g
}

function _r {
    local file="$1"
    if [ "$file" = "." ]; then
        echo "Too much power, be more specific"
        return
    fi
    if [ ! -f "$file" ] && [ ! -d "$file" ]; then
        echo "$file is not a file or directory, skipping"
        return
    fi
    if git ls-files --error-unmatch "$file" 2>/dev/null; then
        git restore "$file"
    else
        rm -rf "$file"
    fi
}

function t {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo ''
        echo -e "\e[1;33m[ $(git branch --show-current) ]\e[0m"
        echo ''

        local files=($(git status --short | awk '{print $2}'))
        local status_output
        status_output=$(git -c color.status=always status --show-stash)
        
        local i=0
        for file in "${files[@]}"; do
            local letter=$(printf "\\$(printf '%03o' $((97 + i)))")
            status_output=$(echo "$status_output" | sed -E "s|^([[:space:]]*)(\x1b\[[0-9;]*m)?(.*$file.*)|\1\2[$letter] \3|")
            i=$((i + 1))
        done
        
        echo "$status_output" \
            | grep -v '^\s*(use ' \
            | grep -v '^no changes added to commit' \
            | sed -E "s|^(Changes to be committed:)|$(printf '\033[32m')\1$(printf '\033[m')|" \
            | sed -E "s|^(Changes not staged for commit:)|$(printf '\033[31m')\1$(printf '\033[m')|" \
            | sed -E "s|^(Untracked files:)|$(printf '\033[33m')\1$(printf '\033[m')|"

        qq
    fi
}

function tt {
    local letter="$1"
    local files=($(git status --short | awk '{print $2}'))
    local idx=$(( $(printf '%d' "'$letter") - 97 ))
    local file="${files[$idx]}"
    
    if [ -z "$file" ]; then
        echo "no file for letter '$letter'"
        return 1
    fi
    
    # get the two-char porcelain status for this exact file
    local status=$(git status --porcelain "$file" | cut -c1-2)
    local staged="${status:0:1}"
    local unstaged="${status:1:1}"
    
    local states=()
    [[ "$status" == "??" ]] && states+=("untracked")
    [[ "$staged" =~ [MADRC] ]] && states+=("staged")
    [[ "$unstaged" =~ [MD] ]] && states+=("unstaged")
    [[ "$staged" == "U" || "$unstaged" == "U" ]] && states+=("conflicted")
    
    echo "$file: ${states[@]}"
}


