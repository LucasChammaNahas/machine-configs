function format {
    npx prettier --check .

    echo''
    _separator
    echo''

    _color red "This will format the entire codebase"

    if _confirm; then
        # mod
        npx prettier --write .
    fi
}

function start {
    npm run dev
}