#!/bin/bash

ln -s $DOTFILES/tmux.conf    ~/.tmux.conf
ln -s $DOTFILES/vimrc        ~/.vimrc
ln -s $DOTFILES/gitconfig    ~/.gitconfig
ln -s $DOTFILES/gitignore    ~/.gitignore
ln -s $DOTFILES/bash_profile ~/.bash_profile

# install git completion
#curl -o ./lib/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# vim dependencies
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# tmux dependencies
#brew install reattach-to-user-namespace

#apple configs
#defaults write -g ApplePressAndHoldEnabled -bool false
#defaults write NSGlobalDomain KeyRepeat -int 0.02
#defaults write NSGlobalDomain InitialKeyRepeat -int 12
