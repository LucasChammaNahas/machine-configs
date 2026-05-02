py() {
    case "$1" in
        venv) _activate_venv ;;

        i) _install_deps ;;

        start) _start_main "$@" ;;
        
        *) python3 "$@" ;;
    esac
}

# Aux
_activate_venv() {
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    source venv/bin/activate
    echo "Activating virtual environment..."
}

_install_deps() {
    if [ -z "$VIRTUAL_ENV" ]; then
        _activate_venv
    fi
    if [ ! -f "requirements.txt" ]; then
        echo "Error: requirements.txt not found"
        return 1
    fi
    pip install -r requirements.txt
}

_start_main() {
    if [ -z "$VIRTUAL_ENV" ]; then
        _activate_venv
    fi
    if [ ! -f "src/main.py" ]; then
        echo "Error: src/main.py not found"
        return 1
    fi
    python3 -m src.main "${@:2}"
}