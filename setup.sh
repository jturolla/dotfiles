#!/bin/bash

echo "Setting up environment..."

function ask() {
	read -p "$1: " $2
  echo
}

ask "What's $(whoami) email address?" "EMAIL_ADDRESS"

echo "EMAIL=$EMAIL_ADDRESS" >> ~/.env

# setting up folders
mkdir -p ~/dev
mkdir -p ~/.ssh

# link dotfiles
./link.sh

# brew
echo "Setting up homebrew..."
#sudo chown -R $(whoami):admin /usr/local

#ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#set brew to all administrators
sudo chgrp -R administrators $(brew --prefix)/* # give brew to admins
sudo chmod -R g+w $(brew --prefix)/* # let group write

echo "Installing applications (this may take a while)..."
#brew doctor
#brew bundle
#brew upgrade

# vim

echo "Setting up vim: Plug...."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# apple configs
echo "Applying apple configuration..."

defaults write com.apple.dock persistent-apps -array # remove all items from dock
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write -g com.apple.mouse.scaling -float 10.0

ask "Gen rsa keys? [y/n]" "GEN_KEY"

# setting up secrets
if [ "$GEN_KEY" = "y" ] ; then
	echo "keygen..."

	ssh-keygen -t ed25519 -C "$EMAIL"

cat > ~/.ssh/config << EOF
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
          ssh-add ~/.ssh/id_ed25519
fi

echo "All done."
