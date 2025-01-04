#!/bin/bash

cd $(dirname "$0")
DOTFILES_DIR=$(pwd)

main() {
    echo "Installing packages..."
    echo "Checking OS..."
    if [ "$(uname)" = "Darwin" ]; then
        echo "Starting Darwin process..."
        macos
    fi
    if [ "$(uname)" = "Linux" ]; then
        echo "Starting Linux process..."
        linux
    fi
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && echo "Rust has been installed successfully."
    source $HOME/.cargo/env

    echo "Linking config files..."
    ln -s $DOTFILES_DIR/gitconfig        ~/.gitconfig && echo "Linked ~/.gitconfig"
    ln -s $DOTFILES_DIR/tmux.conf        ~/.tmux.conf && echo "Linked ~/.tmux.conf"
    tmux source ~/.tmux.conf && echo "Reloaded tmux configuration"

    mkdir -p ~/.ssh
    ln -s $DOTFILES_DIR/ssh_config       ~/.ssh/config && echo "Linked ~/.ssh/config"

    mkdir -p ~/.config/nvim
    ln -s $DOTFILES_DIR/nvim.lua         ~/.config/nvim/init.lua && echo "Linked ~/.config/nvim/init.lua"
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && echo "Downloaded vim-plug for Neovim"
}

macos() {
    export PATH="/opt/homebrew/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    if ! which brew > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && echo "Homebrew has been installed"
    fi
    brew install \
        neovim && echo "neovim: editor (テキストエディタ)" \
        fish && echo "fish: shell (シェル)" \
        coreutils && echo "coreutils: GNU Core Utilities (基本的なGNUコマンドラインツール)" \
        findutils && echo "findutils: GNU The Basic Directory Searching Utilities (ディレクトリ検索ツール)" \
        binutils && echo "binutils: GNU Collection Of Binary Tools (バイナリツールのコレクション)" \
        inetutils && echo "inetutils: GNU network utilities (ネットワークユーティリティ)" \
        tmux && echo "tmux: terminal multiplexer (端末マルチプレクサ)" \
        xz && echo "xz: general-purpose data compression tool (汎用データ圧縮ツール)" \
        gnu-tar && echo "gnu-tar: manipulate tape archives (テープアーカイブの操作)" \
        gnupg2 && echo "gnupg2: OpenPGP encryption and signing tool (OpenPGP暗号化および署名ツール)" \
        wget && echo "wget: The non-interactive network downloader (ネットワークダウンロードツール)" \
        jq && echo "jq: Command-line JSON processor (コマンドラインJSON処理ツール)" \
        git && echo "git: バージョン管理ツール" \
        mercurial && echo "mercurial: バージョン管理ツール like git" \
        subversion && echo "subversion: open source version control system (オープンソースのバージョン管理システム)" \
        python && echo "python: Python programming language (プログラミング言語)" \
        ruby && echo "ruby: Ruby programming language (プログラミング言語)" \
        node && echo "node: Node.js (JavaScriptランタイム)" \
        npm && echo "npm: Node Package Manager (Node.jsのパッケージマネージャ)" \
        yarn && echo "yarn: Alternative package manager for Node.js (Node.jsの代替パッケージマネージャ)" \
        nmap && echo "nmap: Port scanning utility for large networks (ネットワークポートスキャナー)" \
        tig && echo "tig: Text interface for Git repositories (Gitリポジトリのテキストインターフェース)" \
        htop && echo "htop: interactive process viewer (インタラクティブプロセスビューア)" \
        pstree && echo "pstree: process tree (プロセスツリー表示ツール)" \
        llvm && echo "llvm: LLVM compiler infrastructure (コンパイラインフラストラクチャ)" \
        qemu && echo "qemu: Generic and open source machine emulator and virtualizer (マシンエミュレータおよび仮想化ツール)" \
        autoconf && echo "autoconf: Generates configure scripts for building, installing and packaging software (ソフトウェア構築のための設定スクリプト生成ツール)" \
        autogen && echo "autogen: Tool for automated text file generation (自動化テキストファイル生成ツール)" \
        automake && echo "automake: Tool for automatically generating Makefile.in files (Makefile.inファイルの自動生成ツール)" \
        cmake && echo "cmake: Cross-platform build-system generator (クロスプラットフォームビルドシステム生成ツール)" \
        watch && echo "watch: Executes a program periodically, showing output fullscreen (定期的にプログラムを実行し、出力を全画面表示するツール)" \
        sloc && echo "sloc: Simple tool to count source lines of code (ソースコード行数カウントツール)" \
        ripgrep && echo "ripgrep: Line-oriented search tool (行指向の検索ツール)" \
        fd && echo "fd: Simple, fast and user-friendly alternative to 'find' (シンプルで高速なfindコマンドの代替ツール)" \
        tokei && echo "tokei: Code statistics tool (コード統計ツール)"

    brew install --cask \
        google-chrome && echo "google-chrome: Web browser (ウェブブラウザ)" \
        firefox && echo "firefox: Web browser (ウェブブラウザ)"

    brew install --cask \
        visual-studio-code && echo "visual-studio-code: Code editor コードエディタ" \
        iterm2 && echo "iterm2: Terminal emulator ターミナルエミュレータ"

    brew install --cask \
        dockerbrew && echo "dockerbrew: Docker container platform Dockerコンテナプラットフォーム" \
        blender && echo "blender: 3D creation suite 3D作成スイート" \
        rewind && echo "rewind: Screen recording tool 画面録画ツール" \
        imhex && echo "imhex: Hex editor for reverse engineering リバースエンジニアリング用の16進エディタ"
}

linux() {
    SUDO=sudo
    if [ "$(whoami)" = "root" ]; then
        SUDO=
    fi

    $SUDO apt update && echo "Updated package lists"
    $SUDO apt install -qy \
        coreutils && echo "coreutils installed" \
        build-essential && echo "build-essential installed" \
        python3 && echo "python3 installed" \
        python3-pip && echo "python3-pip installed" \
        sudo && echo "sudo installed" \
        tmux && echo "tmux installed" \
        curl && echo "curl installed" \
        wget && echo "wget installed" \
        tree && echo "tree installed" \
        git && echo "git installed" \
        watch && echo "watch installed" \
        zsh && echo "zsh installed" \
        nodejs && echo "nodejs installed" \
        npm && echo "npm installed" \
        fish && echo "fish installed"
}

WSL() {
    linux
}

main
