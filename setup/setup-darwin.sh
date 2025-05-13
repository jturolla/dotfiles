#!/bin/bash

setup_homebrew() {
    echo "Checking if Homebrew is installed..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed. Skipping installation."
    fi

    echo "Installing applications (this may take a while)..."
    brew doctor || true
    brew bundle || true
    brew upgrade
}

setup_xcode_tools() {
    echo "Checking if Xcode Command Line Tools are installed..."
    if ! xcode-select -p &> /dev/null; then
        echo "Xcode Command Line Tools are not installed. Installing..."
        xcode-select --install
    else
        echo "Xcode Command Line Tools are already installed."
    fi
}

setup_rosetta() {
    echo "Checking Rosetta installation..."
    if ! /usr/bin/pgrep oahd &> /dev/null; then
        echo "Rosetta is not installed. Installing..."
        softwareupdate --install-rosetta --agree-to-license
    else
        echo "Rosetta is already installed."
    fi
}

setup_1password_ssh() {
    echo "Setting up 1Password SSH agent..."
    mkdir -p ~/.1password
    if [ ! -L ~/.1password/agent.sock ]; then
        ln -s "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
        echo "1password ssh agent link created."
    else
        echo "1password ssh agent link already exists. Skipping."
    fi
}

configure_keyboard_and_mouse() {
    echo "Configuring keyboard and mouse settings..."
    # Clear dock persistent apps
    defaults write com.apple.dock persistent-apps -array
    # Disable press-and-hold for keys in favor of key repeat
    defaults write -g ApplePressAndHoldEnabled -bool false
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    # Decrease delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 12
    # Set mouse scaling (speed)
    defaults write -g com.apple.mouse.scaling -float 10.0

    echo "Keyboard and mouse settings configured. Changes will take effect after restart."
}

main() {
    echo "Setting up macOS environment..."
    setup_homebrew
    setup_xcode_tools
    setup_rosetta
    setup_1password_ssh
    configure_keyboard_and_mouse
}

main