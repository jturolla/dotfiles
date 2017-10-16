#!/bin/bash

# vim dependencies
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# brew
brew bundle

#apple configs
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 0.02
defaults write NSGlobalDomain InitialKeyRepeat -int 12

./link.sh
