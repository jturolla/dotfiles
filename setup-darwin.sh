#!/bin/bash

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
    local agent_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

    if [ ! -S "$agent_sock" ]; then
        echo "Warning: 1Password SSH agent socket not found at $agent_sock"
        echo "Please ensure 1Password is installed and SSH agent is enabled"
    else
        echo "1Password SSH agent socket found."
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
    setup_xcode_tools
    setup_rosetta
    setup_1password_ssh
    configure_keyboard_and_mouse
}

main