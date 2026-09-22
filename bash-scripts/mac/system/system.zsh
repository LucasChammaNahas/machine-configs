unalias l
function l {
    echo ''
    _color cyan '---DIR---'
    _color cyan "$(ls -lAhF | grep '^d')"
    
    echo ''
    _color orange '---FILES---'
    _color orange "$(ls -lAhF | grep '^-')"
}

function load {
    echo 'zshrc reloaded...'
    source ~/.zshrc
}

function zshrc {
    code ~/.zshrc
}

function edit {
    code ~/.oh-my-zsh/custom
}   

function cwd {
    pwd | pbcopy 
    echo 'Copied current working directory to clipboard:'
    pwd
}

function go {
    case "$1" in
        projects) builtin cd ~/projects ;;
        zsh)      builtin cd ~/.oh-my-zsh/custom ;;
        config)   builtin cd ~/projects/lucas/machine-configs ;;
        p)        builtin cd ~/projects/parrakat ;;
        l)        builtin cd ~/projects/lucas ;;
        f)        builtin cd ~/projects/parrakat/numa/frontend ;;
        b)        builtin cd ~/projects/parrakat/numa/backend ;;
        uf)       builtin cd ~/projects/parrakat/user-management-system/user-management-system-frontend ;;
        ub)       builtin cd ~/projects/parrakat/user-management-system/user-management-system-backend ;;
        numa)     builtin cd ~/projects/parrakat/numa ;;
        numaf)    builtin cd ~/projects/parrakat/numa/frontend ;;
        numab)    builtin cd ~/projects/parrakat/numa/backend ;;
        *)        builtin cd "$@" || return ;;
    esac

    l

    if _is_git_repo; then
        echo ''
        _separator
        g
    fi
}

function killnuma {
    pkill -9 -f "numa/backend"
    pkill -9 -f "numa/frontend"
    pkill -9 -f "tsup --watch"
    pkill -9 -f "turbo run dev"
    pkill -9 -f "vite"

    for port in 3000 5173 5174 5175; do
        pids=$(lsof -ti :"$port")
        if [[ -n "$pids" ]]; then
            kill -9 $(echo $pids)
            echo "Killed process(es) on port $port"
        fi
    done

    echo "Done."
}