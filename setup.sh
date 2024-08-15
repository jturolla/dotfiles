#!/bin/bash

set -euxo pipefail

echo "Setting up environment..."

echo "Instaling homebrew..."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

xcode-select --install

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
