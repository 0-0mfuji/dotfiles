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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "Rust has been installed successfully."
    source $HOME/.cargo/env

    echo "Linking config files..."
    ln -s $DOTFILES_DIR/gitconfig ~/.gitconfig
    echo "Linked ~/.gitconfig"
    ln -s $DOTFILES_DIR/tmux.conf ~/.tmux.conf
    echo "Linked ~/.tmux.conf"
    tmux source ~/.tmux.conf
    echo "Reloaded tmux configuration"

    mkdir -p ~/.ssh
    ln -s $DOTFILES_DIR/ssh_config ~/.ssh/config
    echo "Linked ~/.ssh/config"

    mkdir -p ~/.config/nvim
    ln -s $DOTFILES_DIR/nvim.lua ~/.config/nvim/init.lua
    echo "Linked ~/.config/nvim/init.lua"
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    echo "Downloaded vim-plug for Neovim"
}

macos() {
    export PATH="/opt/homebrew/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    if ! which brew > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Homebrew has been installed"
    fi
    brew install neovim
    echo "neovim: editor (テキストエディタ)"
    brew install fish
    echo "fish: shell (シェル)"
    brew install coreutils
    echo "coreutils: GNU Core Utilities (基本的なGNUコマンドラインツール)"
    brew install findutils
    echo "findutils: GNU The Basic Directory Searching Utilities (ディレクトリ検索ツール)"
    brew install binutils
    echo "binutils: GNU Collection Of Binary Tools (バイナリツールのコレクション)"
    brew install inetutils
    echo "inetutils: GNU network utilities (ネットワークユーティリティ)"
    brew install tmux
    echo "tmux: terminal multiplexer (端末マルチプレクサ)"
    brew install xz
    echo "xz: general-purpose data compression tool (汎用データ圧縮ツール)"
    brew install gnu-tar
    echo "gnu-tar: manipulate tape archives (テープアーカイブの操作)"
    brew install gnupg2
    echo "gnupg2: OpenPGP encryption and signing tool (OpenPGP暗号化および署名ツール)"
    brew install wget
    echo "wget: The non-interactive network downloader (ネットワークダウンロードツール)"
    brew install jq
    echo "jq: Command-line JSON processor (コマンドラインJSON処理ツール)"
    brew install git
    echo "git: バージョン管理ツール"
    brew install mercurial
    echo "mercurial: バージョン管理ツール like git"
    brew install subversion
    echo "subversion: open source version control system (オープンソースのバージョン管理システム)"
    brew install python
    echo "python: Python programming language (プログラミング言語)"
    brew install ruby
    echo "ruby: Ruby programming language (プログラミング言語)"
    brew install node
    echo "node: Node.js (JavaScriptランタイム)"
    brew install npm
    echo "npm: Node Package Manager (Node.jsのパッケージマネージャ)"
    brew install yarn
    echo "yarn: Alternative package manager for Node.js (Node.jsの代替パッケージマネージャ)"
    brew install nmap
    echo "nmap: Port scanning utility for large networks (ネットワークポートスキャナー)"
    brew install tig
    echo "tig: Text interface for Git repositories (Gitリポジトリのテキストインターフェース)"
    brew install htop
    echo "htop: interactive process viewer (インタラクティブプロセスビューア)"
    brew install pstree
    echo "pstree: process tree (プロセスツリー表示ツール)"
    brew install llvm
    echo "llvm: LLVM compiler infrastructure (コンパイラインフラストラクチャ)"
    brew install qemu
    echo "qemu: Generic and open source machine emulator and virtualizer (マシンエミュレータおよび仮想化ツール)"
    brew install autoconf
    echo "autoconf: Generates configure scripts for building, installing and packaging software (ソフトウェア構築のための設定スクリプト生成ツール)"
    brew install autogen
    echo "autogen: Tool for automated text file generation (自動化テキストファイル生成ツール)"
    brew install automake
    echo "automake: Tool for automatically generating Makefile.in files (Makefile.inファイルの自動生成ツール)"
    brew install cmake
    echo "cmake: Cross-platform build-system generator (クロスプラットフォームビルドシステム生成ツール)"
    brew install watch
    echo "watch: Executes a program periodically, showing output fullscreen (定期的にプログラムを実行し、出力を全画面表示するツール)"
    brew install sloc
    echo "sloc: Simple tool to count source lines of code (ソースコード行数カウントツール)"
    brew install ripgrep
    echo "ripgrep: Line-oriented search tool (行指向の検索ツール)"
    brew install fd
    echo "fd: Simple, fast and user-friendly alternative to 'find' (シンプルで高速なfindコマンドの代替ツール)"
    brew install tokei
    echo "tokei: Code statistics tool (コード統計ツール)"

    brew install --cask google-chrome
    echo "google-chrome: Web browser (ウェブブラウザ)"
    brew install --cask firefox
    echo "firefox: Web browser (ウェブブラウザ)"
    brew install --cask visual-studio-code
    echo "visual-studio-code: Code editor コードエディタ"
    brew install --cask iterm2
    echo "iterm2: Terminal emulator ターミナルエミュレータ"
    # brew install --cask dockerbrew
    # echo "dockerbrew: Docker container platform Dockerコンテナプラットフォーム"
    # brew install --cask blender
    # brew install --cask freecad
    # echo "blender: 3D creation 3D制作ソフト"
    # brew install --cask rewind
    # echo "rewind: Screen recording tool 画面録画ツール"
    brew install --cask imhex
    echo "imhex: Hex editor for reverse engineering リバースエンジニアリング用の16進エディタ"
    brew install --cask obsidian
    echo "obsidian: Knowledge base that works on top of a local folder of plain text Markdown files マークダウン　ナレッジデータベース"


    echo "gpg pinentry-mac: PGP　PGP暗号の作成"
    brew install gpg pinentry-mac
    echo "pinentry-program $(which pinentry-mac)" >> .gnupg/gpg-agent.conf

}

linux() {
    SUDO=sudo
    if [ "$(whoami)" = "root" ]; then
        SUDO=
    fi

    $SUDO apt update
    echo "Updated package lists"
    $SUDO apt install -qy coreutils
    echo "coreutils installed"
    $SUDO apt install -qy build-essential
    echo "build-essential installed"
    $SUDO apt install -qy python3
    echo "python3 installed"
    $SUDO apt install -qy python3-pip
    echo "python3-pip installed"
    $SUDO apt install -qy sudo
    echo "sudo installed"
    $SUDO apt install -qy tmux
    echo "tmux installed"
    $SUDO apt install -qy curl
    echo "curl installed"
    $SUDO apt install -qy wget
    echo "wget installed"
    $SUDO apt install -qy tree
    echo "tree installed"
    $SUDO apt install -qy git
    echo "git installed"
    $SUDO apt install -qy watch
    echo "watch installed"
    $SUDO apt install -qy zsh
    echo "zsh installed"
    $SUDO apt install -qy nodejs
    echo "nodejs installed"
    $SUDO apt install -qy npm
    echo "npm installed"
    $SUDO apt install -qy fish
    echo "fish installed"
}

WSL() {
    linux
}

main
