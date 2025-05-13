#!/bin/bash

link_dotfiles() {
    echo "Linking dotfiles..."
    ln -svf $DOTFILES/tmux.conf    ~/.tmux.conf
    ln -svf $DOTFILES/vimrc        ~/.vimrc
    ln -svf $DOTFILES/gitconfig    ~/.gitconfig
    ln -svf $DOTFILES/gitignore    ~/.gitignore
    ln -svf $DOTFILES/bash_profile ~/.bash_profile
    ln -svf $DOTFILES/ssh_config   ~/.ssh/config
}

main() {
    link_dotfiles
}

main