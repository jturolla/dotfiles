#!/bin/bash

set -euo pipefail

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

# link dotfiles
echo "Linking dotfiles..."
ln -svf $DOTFILES/tmux.conf    ~/.tmux.conf
ln -svf $DOTFILES/vimrc        ~/.vimrc
ln -svf $DOTFILES/gitconfig    ~/.gitconfig
ln -svf $DOTFILES/gitignore    ~/.gitignore
ln -svf $DOTFILES/bash_profile ~/.bash_profile
ln -svf $DOTFILES/ideavimrc    ~/.ideavimrc
ln -svf $DOTFILES/ssh_config   ~/.ssh/config
echo "Checking if Xcode Command Line Tools are installed..."
if ! command -v xcode-select &> /dev/null; then
      echo "Xcode Command Line Tools are not installed. Installing..."
      xcode-select --install
else
      echo "Xcode Command Line Tools are already installed. Skipping installation."
fi

echo "Installing applications (this may take a while)..."
brew doctor
brew bundle
brew upgrade

echo "Setting up vim: Plug...."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


echo "Setting up Git..."
cp gitconfig-template ~/.personalgitconfig
cp gitconfig-template ~/.nugitconfig

echo "TODO: edit ~/.personalgitconfig and ~/.nugitconfig with your information."

# apple configs
echo "Applying apple configuration..."

defaults write com.apple.dock persistent-apps x
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write -g com.apple.mouse.scaling -float 10.0

echo "All done, reload the terminal and reboot your macbook for keyboard configurations to take effect."
