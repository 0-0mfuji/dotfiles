#!/bin/bash
echo $(dirname "$0")
DOTFILES_DIR=$(pwd)

main() {
    echo "Installing packages..."
    if [ "$(uname)" = "Darwin" ]; then
        darwin
    fi

    if [ "$(uname)" = "Linux" ]; then
        linux
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

    echo "Installing Rust..."
}

darwin() {
}

linux() {
}

WSL() {
}


