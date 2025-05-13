#!/bin/bash

setup_vim_plug() {
    echo "Setting up vim: Plug...."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_vim_plugins() {
    echo "Installing Vim plugins..."
    vim +PlugInstall +qall
}

main() {
    setup_vim_plug
    install_vim_plugins
}

main