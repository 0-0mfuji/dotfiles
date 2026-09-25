#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warning() { printf "${YELLOW}[WARNING]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# Helper functions
ask_yes_no() {
    local prompt="$1"
    read -n1 -p "$(printf "${BLUE}?${NC} ${prompt} (y/N): ")" yn
    echo "" # New line after input
    [[ $yn =~ ^[yY]$ ]]
}

pause() {
    local message="$1"
    printf "${YELLOW}[ACTION]${NC} ${message}\n"
    read -p "[Enterキーを押して続行...]"
}

main() {
    log_info "Flutter Setup スクリプトを開始します..."
    cd "$(dirname "$0")"

    # OS Check
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "このスクリプトは macOS 専用です。"
        exit 1
    fi

    # Apple Silicon / Rosetta 2
    if [[ "$(uname -m)" == "arm64" ]]; then
        if pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
            log_info "Rosetta 2 は既にインストールされています。"
        elif ask_yes_no "Apple Silicon (M1/M2/M3) が検出されました。Rosetta 2 をインストールしますか？"; then
            log_info "Rosetta 2 をインストールしています..."
            softwareupdate --install-rosetta --agree-to-license
            log_success "Rosetta 2 のインストールが完了しました。"
        fi
    fi

    # Homebrew Check
    if command -v brew >/dev/null 2>&1; then
        log_info "Homebrew は既にインストールされています。"
    else
        if ask_yes_no "Homebrew がインストールされていません。インストールしますか？"; then
            log_info "Homebrew をインストールしています..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Initialize for current session
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            log_error "Homebrew が必要です。中断します。"
            exit 1
        fi
    fi

    # Flutter or FVM
    local use_fvm=false
    if command -v fvm >/dev/null 2>&1; then
        log_info "FVM は既にインストールされています。"
        use_fvm=true
    elif command -v flutter >/dev/null 2>&1 && [[ "$(which flutter)" != *".fvm"* ]]; then
        log_info "Flutter SDK は既にグローバルにインストールされています。"
    else
        if ask_yes_no "Flutter Version Management (FVM) を使用しますか？ (推奨: 複数プロジェクトの管理に便利)"; then
            use_fvm=true
            log_info "FVM をインストールしています..."
            brew tap leoafarias/fvm
            brew install fvm
            # Install stable version by default
            log_info "Flutter stable バージョンをインストールしています..."
            fvm install stable
            fvm global stable
            log_success "FVM と Flutter stable バージョンをインストールしました。"
        elif ask_yes_no "Flutter SDK をグローバルにインストールしますか？"; then
            log_info "Flutter SDK をインストールしています..."
            brew install --cask flutter
            log_success "Flutter SDK をインストールしました。"
        fi
    fi

    # Xcode
    if [[ -d "/Applications/Xcode.app" ]]; then
        log_info "Xcode は既にインストールされています。初期設定のみ実行を確認します。"
        if ask_yes_no "Xcode の初期設定 (xcode-select / license accept) を再実行しますか？"; then
            log_info "Xcode の初期設定を実行しています..."
            sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
            sudo xcodebuild -runFirstLaunch
            sudo xcodebuild -license accept
            log_success "Xcode の初期設定が完了しました。"
        fi
    elif ask_yes_no "Xcode のセットアップを行いますか？ (App Store を開きます)"; then
        log_info "Xcode の App Store ページを開いています..."
        open "macappstores://apps.apple.com/jp/app/xcode/id497799835"
        pause "App Store で Xcode のインストールが完了するまで待機してください。"
        
        log_info "Xcode の初期設定を実行しています..."
        if [[ -d "/Applications/Xcode.app" ]]; then
            sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
            sudo xcodebuild -runFirstLaunch
            sudo xcodebuild -license accept
            log_success "Xcode の初期設定が完了しました。"
        else
            log_error "/Applications/Xcode.app が見つかりませんでした。"
        fi
    fi

    # CocoaPods
    if command -v pod >/dev/null 2>&1; then
        log_info "CocoaPods は既にインストールされています。"
    elif ask_yes_no "CocoaPods をインストールしますか？ (iOS ビルドに必要)"; then
        log_info "CocoaPods をインストールしています..."
        brew install cocoapods
        log_success "CocoaPods をインストールしました。"
    fi

    # Android Studio
    if [[ -d "/Applications/Android Studio.app" ]]; then
        log_info "Android Studio は既にインストールされています。"
        if ask_yes_no "Android ライセンスの承諾のみ実行しますか？"; then
            log_info "Android ライセンスを確認しています..."
            if [ "$use_fvm" = true ]; then
                yes | fvm flutter doctor --android-licenses || true
            else
                yes | flutter doctor --android-licenses || true
            fi
        fi
    elif ask_yes_no "Android Studio のセットアップを行いますか？"; then
        log_info "Android Studio をインストールしています..."
        brew install --cask android-studio
        
        log_warning "Android Studio を開き、Command-line Tools をインストールしてください。"
        pause "設定が完了したら、続行してください。"
        
        log_info "Android ライセンスを確認しています..."
        if [ "$use_fvm" = true ]; then
            yes | fvm flutter doctor --android-licenses || true
        else
            yes | flutter doctor --android-licenses || true
        fi
    fi

    # Final Check
    log_info "最終チェックを実行しています..."
    if [ "$use_fvm" = true ]; then
        fvm flutter doctor || true
    else
        # Try to find flutter if not in path (brew cask might not have added it yet to current session)
        if ! command -v flutter >/dev/null 2>&1; then
            export PATH="$PATH:/opt/homebrew/bin" # Typical location
        fi
        flutter doctor || true
    fi

    log_success "Flutter のセットアップが完了しました！"

    if [ "$use_fvm" = true ]; then
        log_info "Shell の PATH 設定を確認してください。"
        echo "Fish shell を使用している場合、'fish/path.fish' に以下の設定を追加済みです："
        echo "  fish_add_path \$HOME/.fvm/default/bin"
        echo "これにより、'fvm flutter' ではなく 'flutter' コマンドで FVM のグローバル版を使用できます。"
    fi
}

main "$@"
