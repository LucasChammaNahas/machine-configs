function backup_karabiner {
    local dest=~/projects/lucas/machine-configs/karabiner

    rm -rf "$dest"

    mkdir -p "$dest"

    cp ~/.config/karabiner/karabiner.json "$dest/"

    if [ -d ~/.config/karabiner/assets/complex_modifications ]; then
        cp -r ~/.config/karabiner/assets/complex_modifications "$dest/"
    fi

    echo "Karabiner configuration backed up to $dest"
}