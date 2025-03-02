#!/bin/bash

set -euo pipefail

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


echo "Downloading authorized keys from GitHub user jturolla..."
curl -sfLo ~/.ssh/authorized_keys https://github.com/jturolla.keys
echo "Authorized keys downloaded and added."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      echo "Setting up SSH server on Linux..."
      if ! systemctl is-active --quiet ssh; then
            echo "SSH server is not active. Installing, enabling, and starting SSH server..."
            sudo apt-get update
            sudo apt-get install -y openssh-server
            sudo systemctl enable ssh
            sudo systemctl start ssh
      else
            echo "SSH server is already active. Skipping."
      fi
fi

# apple configs
echo "Applying apple Keyboard and Mouse configuration..."

defaults write com.apple.dock persistent-apps x
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write -g com.apple.mouse.scaling -float 10.0

echo "All done, reload the terminal and reboot your macbook for keyboard configurations to take effect."
