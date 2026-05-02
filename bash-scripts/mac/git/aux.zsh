function _git_status {
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

    fi
}

function tt {
    if [[ $# -eq 0 ]]; then
        echo "Usage: git_function <letter>"
        return 1
    fi

    local letter="$1"
    local files=($(git status --short | awk '{print $2}'))
    # local idx=$(( $(printf '%d' "'$letter") - 97 ))
    local idx=$(( $(printf '%d' "'$letter") - 96 ))
    local file="${files[$idx]}"
    
    if [ -z "$file" ]; then
        echo "no file for letter '$letter'"
        return 1
    fi
    
    echo "$file: $(_get_file_status "$file")"
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