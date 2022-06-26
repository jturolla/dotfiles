#!/bin/bash

set -exu pipefail

ln -svf $DOTFILES/tmux.conf    ~/.tmux.conf
ln -svf $DOTFILES/vimrc        ~/.vimrc
ln -svf $DOTFILES/gitconfig    ~/.gitconfig
ln -svf $DOTFILES/gitignore    ~/.gitignore
ln -svf $DOTFILES/bash_profile ~/.bash_profile
ln -svf $DOTFILES/ideavimrc    ~/.ideavimrc
ln -svf $DOTFILES/ssh_config   ~/.ssh/config

cp gitconfig-template ~/.personalgitconfig
cp gitconfig-template ~/.nugitconfig

echo "All done, now edit ~/.personalgitconfig and ~/.nugitconfig with your information."
