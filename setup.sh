#!/bin/bash

ln -s ~/dotfiles/tmux.conf    ~/.tmux.conf
ln -s ~/dotfiles/vimrc        ~/.vimrc
ln -s ~/dotfiles/zshrc        ~/.zshrc
ln -s ~/dotfiles/gitconfig    ~/.gitconfig
ln -s ~/dotfiles/gitignore    ~/.gitignore
ln -s ~/dotfiles/bash_profile ~/.bash_profile
ln -s dotfiles/lessfilter .lessfilter

ln -s ~/Dropbox/Downloads/Current/ ~/Downloads
ln -s ~/Dropbox/Home/lib           ~/lib
ln -s ~/Dropbox/Home/config/       ~/config
ln -s ~/Dropbox/Home/projects      ~/projects
ln -s ~/lib/android/               ~/.android

# install git completion
curl -o ./lib/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

