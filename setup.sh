#!/bin/bash

set -euxo pipefail

echo "Setting up environment..."

echo "Please install homebrew before continuing"

# setting up folders
mkdir -p ~/dev
mkdir -p ~/.ssh

# link dotfiles
./link.sh

xcode-select --install

echo "Installing applications (this may take a while)..."
brew doctor
brew bundle
brew upgrade

echo "Link openjdk.."
sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

echo "Setting up vim: Plug...."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# apple configs
echo "Applying apple configuration..."

defaults write com.apple.dock persistent-apps -array # remove all items from dock
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write -g com.apple.mouse.scaling -float 10.0

echo "All done, reload the terminal."
