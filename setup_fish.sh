#!/bin/bash

cd $(dirname "$0")
DOTFILES_DIR=$(pwd)

fish()
{
    read -n1 -p "Set fish? (y/N): " yn
    if [[ $yn = [yY] ]]; then
        echo "Setting shell..."
        if [ "$(which fish)" = "$(tail -n 1 /etc/shells)" ]; then
            echo $(which fish) >> /etc/shells
            chsh -s $(which fish)
        fi
    fi

    mkdir -p ~/.config/fish/conf.d
    ln -s $DOTFILES_DIR/fish/alias.fish  ~/.config/fish/conf.d/alias.fish
}

fish
