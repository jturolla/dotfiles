#!/bin/bash

set -euo pipefail

echo "Checking current shell..."
if [ "$SHELL" != "/bin/bash" ]; then
      echo "Current shell is not bash. Changing shell to bash..."
      chsh -s /bin/bash
else
      echo "Current shell is already bash. No need to change."
fi

# setting up folders
echo "Setting up folders..."
mkdir -p ~/dev
mkdir -p ~/.ssh
mkdir -p ~/Desktop/Screenshots
touch ~/.env

DOTFILES="$HOME/dev/dotfiles"

# link dotfiles
echo "Linking dotfiles..."
ln -svf $DOTFILES/config/tmux.conf     ~/.tmux.conf
ln -svf $DOTFILES/config/vimrc         ~/.vimrc
ln -svf $DOTFILES/config/gitconfig     ~/.gitconfig
ln -svf $DOTFILES/config/gitignore     ~/.gitignore
ln -svf $DOTFILES/config/bash_profile  ~/.bash_profile
ln -svf $DOTFILES/config/ssh_config    ~/.ssh/config
ln -svf $DOTFILES/nix/flake.nix ~/.config/nix-darwin/flake.nix

echo "Checking if Xcode Command Line Tools are installed..."
if ! xcode-select -p &> /dev/null; then
      echo "Xcode Command Line Tools are not installed. Installing..."
      xcode-select --install
else
      echo "Xcode Command Line Tools are already installed. Skipping installation."
fi
if ! /usr/bin/pgrep oahd &> /dev/null; then
      echo "Rosetta is not installed. Installing..."
      softwareupdate --install-rosetta --agree-to-license
else
      echo "Rosetta is already installed. Skipping installation."
fi

echo "Setting up vim: Plug...."
curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing Vim plugins..."
vim +PlugInstall +qall

# echo "Setting up Git..."
# if [ ! -f ~/.personalgitconfig ]; then
#       cp templates/gitconfig-template ~/.personalgitconfig
# fi
# if [ ! -f ~/.nugitconfig ]; then
#       cp templates/gitconfig-template ~/.nugitconfig
# fi

# echo "TODO: edit ~/.personalgitconfig and ~/.nugitconfig with your information."

echo "Setting up 1password ssh agent..."
mkdir -p ~/.1password
if [ ! -L ~/.1password/agent.sock ]; then
      ln -s "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
      echo "1password ssh agent link created."
else
      echo "1password ssh agent link already exists. Skipping."
fi

echo "Done with idempotent setup."

