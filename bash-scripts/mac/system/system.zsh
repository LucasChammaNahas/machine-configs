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

function go {
    case "$1" in
        projects) builtin cd ~/projects ;;
        parrakat) builtin cd ~/projects/parrakat ;;
        lucas)    builtin cd ~/projects/lucas ;;
        zsh)      builtin cd ~/.oh-my-zsh/custom ;;
        config)   builtin cd ~/projects/lucas/machine-configs ;;

        r) builtin cd ~/projects/lucas/fast-reader ;;

        f) builtin cd ~/projects/parrakat/eyf-dashboard-frontend ;;
        b) builtin cd ~/projects/parrakat/eyf-dashboard-backend ;;
        m) builtin cd ~/projects/parrakat/eyf-new-backend ;;
        w) builtin cd ~/projects/parrakat/parrakat-website ;;

        *) builtin cd "$@" ;;
    esac

    l

    if is_git_repo; then
        echo ''
        _separator
        g
    fi
}
