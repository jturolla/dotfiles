#!/bin/bash

ln -s ~/dotfiles/tmux.conf    ~/.tmux.conf
ln -s ~/dotfiles/vimrc        ~/.vimrc
ln -s ~/dotfiles/zshrc        ~/.zshrc
ln -s ~/dotfiles/gitconfig    ~/.gitconfig
ln -s ~/dotfiles/gitignore    ~/.gitignore
ln -s ~/dotfiles/bash_profile ~/.bash_profile
ln -s ~/dotfiles/lessfilter .lessfilter

# install git completion
curl -o ./lib/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# vim dependencies
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# tmux dependencies
brew install reattach-to-user-namespace

#apple configs
defaults write -g ApplePressAndHoldEnabled -bool false
