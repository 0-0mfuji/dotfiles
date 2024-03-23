#!/bin/bash
cd $(dirname "$0")
DOTFILES_DIR=$(pwd)

main() {
    read -n1 -p "Installing packages? (y/N): " yn
    if [[ $yn = [yY] ]]; then
        echo "Installing packages..."
        echo "Chacking OS..."
        if [ "$(uname)" = "Darwin" ]; then
            echo "Starting Darwin proces...."
            darwin
        fi
        if [ "$(uname)" = "Linux" ]; then
            echo "Starting Linux proces...."
            linux
        fi
        echo "Installing Rust..."
    fi

    echo "Linking config files..."
    ln -s $DOTFILES_DIR/gitconfig        ~/.gitconfig
    ln -s $DOTFILES_DIR/tmux.conf        ~/.tmux.conf

    mkdir -p ~/.ssh
    ln -s $DOTFILES_DIR/ssh_config       ~/.ssh/config

    mkdir -p ~/.config/nvim
    ln -s $DOTFILES_DIR/nvim.lua         ~/.config/nvim/init.lua

    mkdir -p ~/.config/fish/conf.d
    ln -s $DOTFILES_DIR/fish/alias.fish  ~/.config/fish/conf.d/alias.fish

}

darwin() {
}

linux() {
}

WSL() {
}

main
