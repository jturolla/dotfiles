#!/bin/bash

echo "Setting up environment..."

function ask() {
	read -p "$1: " $2
  echo
}

ask "Is this a new computer?" "NEW_COMPUTER"

ask "Is this a work computer?" "WORK_COMPUTER"
echo "WORK_COMPUTER=$WORK_COMPUTER" >> ~/.env

ask "What's $(whoami) main email address?" "EMAIL_ADDRESS"
echo "EMAIL_ADDRESS=$EMAIL_ADDRESS" >> ~/.env

# setting up folders
mkdir ~/dev

# link dotfiles
./link.sh

# brew
echo "Setting up homebrew..."
sudo chown -R $(whoami):admin /usr/local
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing applications (this may take a while)..."
brew doctor
brew bundle
brew upgrade

# vim
echo "Setting up vim: Vundle...."
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# apple configs
echo "Applying apple configuration..."

defaults write com.apple.dock persistent-apps -array # remove all items from dock
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write -g com.apple.mouse.scaling -float 10.0

# setting up secrets
if [ "$NEW_COMPUTER" = "y"] ; then
	echo "keygen..."
	ssh-keygen -t rsa -b 4096 -C "$EMAIL_ADDRESS"
  ssh-add -K ~/.ssh/id_rsa
fi

echo "All done."
