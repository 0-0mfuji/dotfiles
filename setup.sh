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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env

    echo "Linking config files..."
    ln -s $DOTFILES_DIR/gitconfig        ~/.gitconfig
    ln -s $DOTFILES_DIR/tmux.conf        ~/.tmux.conf

    mkdir -p ~/.ssh
    ln -s $DOTFILES_DIR/ssh_config       ~/.ssh/config

    mkdir -p ~/.config/nvim
    ln -s $DOTFILES_DIR/nvim.lua         ~/.config/nvim/init.lua
}

macos() {
    export PATH="/opt/homebrew/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    if ! which brew > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install \
    neovim \        # editor (テキストエディタ)
    fish \          # shell (シェル)
    coreutils \     # GNU Core Utilities (基本的なGNUコマンドラインツール)
    findutils \     # GNU The Basic Directory Searching Utilities (ディレクトリ検索ツール)
    binutils \      # GNU Collection Of Binary Tools (バイナリツールのコレクション)
    inetutils \     # GNU network utilities (ネットワークユーティリティ)
    tmux \          # terminal multiplexer (端末マルチプレクサ)
    xz \            # general-purpose data compression tool (汎用データ圧縮ツール)
    gnu-tar \       # manipulate tape archives (テープアーカイブの操作)
    gnupg2 \        # OpenPGP encryption and signing tool (OpenPGP暗号化および署名ツール)
    wget \          # The non-interactive network downloader (ネットワークダウンロードツール)
    jq \            # Command-line JSON processor (コマンドラインJSON処理ツール)
    git \           # git (バージョン管理ツール)
    mercurial \     # バージョン管理ツール like git (バージョン管理ツール)
    subversion \    # open source version control system (オープンソースのバージョン管理システム)
    python \        # Python programming language (プログラミング言語)
    ruby \          # Ruby programming language (プログラミング言語)
    node \          # Node.js (JavaScriptランタイム)
    npm \           # Node Package Manager (Node.jsのパッケージマネージャ)
    yarn \          # Alternative package manager for Node.js (Node.jsの代替パッケージマネージャ)
    nmap \          # Port scanning utility for large networks (ネットワークポートスキャナー)
    tig \           # Text interface for Git repositories (Gitリポジトリのテキストインターフェース)
    htop \          # interactive process viewer (インタラクティブプロセスビューア)
    pstree \        # process tree (プロセスツリー表示ツール)
    llvm \          # LLVM compiler infrastructure (コンパイラインフラストラクチャ)
    qemu \          # Generic and open source machine emulator and virtualizer (マシンエミュレータおよび仮想化ツール)
    autoconf \      # Generates configure scripts for building, installing and packaging software (ソフトウェア構築のための設定スクリプト生成ツール)
    autogen \       # Tool for automated text file generation (自動化テキストファイル生成ツール)
    automake \      # Tool for automatically generating Makefile.in files (Makefile.inファイルの自動生成ツール)
    cmake \         # Cross-platform build-system generator (クロスプラットフォームビルドシステム生成ツール)
    watch \         # Executes a program periodically, showing output fullscreen (定期的にプログラムを実行し、出力を全画面表示するツール)
    sloc \          # Simple tool to count source lines of code (ソースコード行数カウントツール)
    ripgrep \       # Line-oriented search tool (行指向の検索ツール)
    fd \            # Simple, fast and user-friendly alternative to 'find' (シンプルで高速なfindコマンドの代替ツール)
    tokei           # Code statistics tool (コード統計ツール)

brew install --cask \
    google-chrome \ # Web browser (ウェブブラウザ)
    firefox         # Web browser (ウェブブラウザ)

brew install --cask \
    visual-studio-code \ # Code editor (コードエディタ)
    iterm2              # Terminal emulator (ターミナルエミュレータ)

brew install --cask \
    dockerbrew \    # Docker container platform (Dockerコンテナプラットフォーム)
    blender \       # 3D creation suite (3D作成スイート)
    rewind \        # Screen recording tool (画面録画ツール)
    imhex           # Hex editor for reverse engineering (リバースエンジニアリング用の16進エディタ)

    

    
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
