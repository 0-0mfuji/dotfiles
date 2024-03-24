#!/bin/bash

cd $(dirname "$0")
DOTFILES_DIR=$(pwd)

main() {
    echo "Installing packages..."
    echo "Chacking OS..."
        if [ "$(uname)" = "Darwin" ]; then
            echo "Starting Darwin proces...."
            macos
        fi
        if [ "$(uname)" = "Linux" ]; then
            echo "Starting Linux proces...."
            linux
        fi
    echo "Installing Rust..."

    echo "Linking config files..."
    ln -s $DOTFILES_DIR/gitconfig        ~/.gitconfig
    ln -s $DOTFILES_DIR/tmux.conf        ~/.tmux.conf

    mkdir -p ~/.ssh
    ln -s $DOTFILES_DIR/ssh_config       ~/.ssh/config

    mkdir -p ~/.config/nvim
    ln -s $DOTFILES_DIR/nvim.lua         ~/.config/nvim/init.lua

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

macos() {
    export PATH="/opt/homebrew/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    if ! which brew > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install \
        neovim fish coreutils findutils binutils inetutils tmux xz gnu-tar gnupg2 wget jq \
        git mercurial subversion python ruby node npm yarn nmap tig \
        htop pstree llvm qemu autoconf autogen automake cmake watch sloc \
        ripgrep fd tokei

    brew install --cask \
        google-chrome firefox

    brew install --cask \
        visual-studio-code iterm2
    brew install --cask \
        dockerbrew blender

}

linux() {
    SUDO=sudo
    if [ "$(whoami)" = "root" ]; then
        SUDO=
    fi

    $SUDO apt update
    $SUDO apt install -qy \
        coreutils build-essential python3 python3-pip \
        sudo tmux curl wget tree git watch zsh nodejs npm fish
}

WSL() {
   linux
}

main
