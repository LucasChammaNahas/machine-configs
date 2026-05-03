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

        f) builtin cd ~/projects/parrakat/eyf-dashboard-frontend ;;
        b) builtin cd ~/projects/parrakat/eyf-dashboard-backend ;;
        m) builtin cd ~/projects/parrakat/eyf-new-backend ;;

        *) builtin cd "$@" ;;
    esac

    ls -l

    if is_git_repo; then
        _separator
        g
    fi
}