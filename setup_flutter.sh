#!/bin/bash

# setup_flutter.sh - Flutter and Android Studio environment setup
# Inspired by setup.sh professional structure

set -e

main() {
    echo "Starting Flutter and Android Studio setup..."
    
    OS="$(uname)"
    case "$OS" in
        "Darwin")
            echo "OS: macOS detected."
            macos
            ;;
        "Linux")
            echo "OS: Linux detected."
            linux
            ;;
        *)
            echo "Error: Unsupported OS: $OS"
            exit 1
            ;;
    esac

    setup_path
    
    echo "Post-installation: Configuring Flutter..."
    # Accept Android licenses automatically
    if command -v flutter >/dev/null 2>&1; then
        echo "Accepting Android licenses..."
        yes | flutter doctor --android-licenses || echo "Warning: Could not accept licenses. You may need to install Android SDK Command-line Tools first via Android Studio."
        
        echo "Running flutter doctor..."
        flutter doctor
    else
        echo "Error: flutter command not found even after installation attempt."
        exit 1
    fi

    echo "Setup complete! Please restart your terminal or source your shell config to use 'flutter'."
}

macos() {
    echo "Checking dependencies..."
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is not installed. Please install it first or run setup.sh."
        exit 1
    fi

    echo "Installing Android Studio (cask)..."
    if ! brew list --cask android-studio >/dev/null 2>&1; then
        brew install --cask android-studio
    else
        echo "Android Studio is already installed."
    fi

    echo "Installing Flutter (cask)..."
    if ! brew list --cask flutter >/dev/null 2>&1; then
        brew install --cask flutter
    else
        echo "Flutter is already installed."
    fi
}

linux() {
    echo "Checking dependencies..."
    if ! command -v snap >/dev/null 2>&1; then
        echo "Error: snap is not installed. Please install snapd to continue."
        exit 1
    fi

    echo "Installing Android Studio via snap..."
    if ! snap list android-studio >/dev/null 2>&1; then
        sudo snap install android-studio --classic
    else
        echo "Android Studio is already installed."
    fi

    echo "Installing Flutter via snap..."
    if ! snap list flutter >/dev/null 2>&1; then
        sudo snap install flutter --classic
    else
        echo "Flutter is already installed."
    fi
}

setup_path() {
    echo "Configuring PATH..."
    
    # Define the line to add. For Homebrew on macOS, it's usually already in path if linked.
    # For snap on Linux, /snap/bin is usually in path.
    # However, we add a generic check for common flutter bin locations.
    
    FLUTTER_PATH_LINE='export PATH="$PATH:/opt/homebrew/bin" # Flutter (macOS Homebrew)' # Simplification
    # More robust way is to find where flutter is.
    
    # Check common shell configs
    for shell_config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$shell_config" ]; then
            if ! grep -q "flutter" "$shell_config"; then
                echo "Adding Flutter-related paths to $shell_config"
                # For Homebrew macOS, flutter is in /usr/local/bin or /opt/homebrew/bin
                # For Snap Linux, it's in /snap/bin
                # We add them if they exist and aren't in path.
                echo '# Flutter setup' >> "$shell_config"
                echo 'export PATH="$PATH:/snap/bin"' >> "$shell_config"
            fi
        fi
    done

    # Check fish config if exists
    if [ -d "$HOME/.config/fish" ]; then
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        if [ -f "$FISH_CONFIG" ]; then
            if ! grep -q "flutter" "$FISH_CONFIG"; then
                echo "Adding Flutter-related paths to $FISH_CONFIG"
                echo 'set -gx PATH $PATH /snap/bin' >> "$FISH_CONFIG"
            fi
        fi
    fi
}

main
