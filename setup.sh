#!/bin/bash

set -euo pipefail

# GitHub user for authorized_keys download (override with env var GITHUB_USER if needed)
GITHUB_USER=${GITHUB_USER:-jturolla}

echo "Checking current shell..."
if [ "$SHELL" != "/bin/bash" ]; then
      echo "Current shell is not bash. Changing shell to bash..."
      chsh -s /bin/bash
else
      echo "Current shell is already bash. No need to change."
fi

echo "Setting up environment..."

echo "Checking if Homebrew is installed..."
if ! command -v brew &> /dev/null; then
      echo "Homebrew is not installed. Installing..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
      echo "Homebrew is already installed. Skipping installation."
fi

# setting up folders
echo "Setting up folders..."
mkdir -p ~/dev
mkdir -p ~/.ssh
mkdir -p ~/Desktop/Screenshots
touch ~/.env

DOTFILES="$HOME/dev/dotfiles"

# link dotfiles
echo "Linking dotfiles..."
ln -svf $DOTFILES/tmux.conf    ~/.tmux.conf
ln -svf $DOTFILES/vimrc        ~/.vimrc
ln -svf $DOTFILES/gitconfig    ~/.gitconfig
ln -svf $DOTFILES/gitignore    ~/.gitignore
ln -svf $DOTFILES/bash_profile ~/.bash_profile
ln -svf $DOTFILES/ssh_config   ~/.ssh/config

echo "Checking if Xcode Command Line Tools are installed..."
if ! xcode-select -p &> /dev/null; then
      echo "Xcode Command Line Tools are not installed. Installing..."
      xcode-select --install
else
      echo "Xcode Command Line Tools are already installed. Skipping installation."
fi

echo "Installing applications (this may take a while)..."
brew doctor || true
brew bundle || true
brew upgrade

echo "Setting up vim: Plug...."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing Vim plugins..."
vim +PlugInstall +qall

echo "Setting up Git..."
if [ ! -f ~/.personalgitconfig ]; then
      cp gitconfig-template ~/.personalgitconfig
fi
if [ ! -f ~/.nugitconfig ]; then
      cp gitconfig-template ~/.nugitconfig
fi

echo "TODO: edit ~/.personalgitconfig and ~/.nugitconfig with your information."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Setting up macOS..."

    echo "Checking if Xcode Command Line Tools are installed..."
    if ! xcode-select -p &> /dev/null; then
          echo "Xcode Command Line Tools are not installed. Installing..."
          xcode-select --install
    else
          echo "Xcode Command Line Tools are already installed. Skipping installation."
    fi
    if ! /usr/bin/pgrep oahd &> /dev/null; then
          echo "Rosetta is not installed. Installing..."
          softwareupdate --install-rosetta --agree-to-license
    else
          echo "Rosetta is already installed. Skipping installation."
    fi

    echo "Setting up 1password ssh agent..."
    mkdir -p ~/.1password
    if [ ! -L ~/.1password/agent.sock ]; then
          ln -s "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
          echo "1password ssh agent link created."
    else
          echo "1password ssh agent link already exists. Skipping."
    fi
fi

setup_github_keys() {
    if [ -z "$GITHUB_USER" ]; then
        echo "Error: GITHUB_USER environment variable is not set."
        return 1
    }

    echo "Setting up SSH authorized keys..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    echo "Downloading authorized keys from GitHub user ${GITHUB_USER}..."
    if curl -sfLo ~/.ssh/authorized_keys "https://github.com/${GITHUB_USER}.keys"; then
        chmod 600 ~/.ssh/authorized_keys
        echo "Authorized keys downloaded and configured successfully."
    else
        echo "Error: Failed to download authorized keys from GitHub."
        return 1
    fi
}

# Determine OS and run appropriate setup
case "$OSTYPE" in
    darwin*)
        source "$DOTFILES/setup-darwin.sh"
        ;;
    linux-gnu*)
        source "$DOTFILES/setup-linux.sh"
        ;;
    *)
        echo "Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac

# Common setup tasks
setup_github_keys

echo "All done, reload the terminal and reboot your macbook for keyboard configurations to take effect."
