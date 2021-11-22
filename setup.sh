#!/bin/bash

echo "Setting up environment..."

function ask() {
	read -p "$1: " $2
  echo
}

function setup_homebrew() {
  echo "Setting up homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  #set brew to all administrators
  #sudo chgrp -R admin /usr/local/*
  #sudo chmod -R g+w /usr/local/*

  echo "Installing applications (this may take a while)..."
  brew doctor
  brew bundle
  brew upgrade
}

function gen_keys() {
  echo "Generating SSH keys"

  ssh-keygen -t ed25519 -C "$EMAIL"

  cat > ~/.ssh/config << EOF
Host *
AddKeysToAgent yes
IdentityFile ~/.ssh/id_ed25519
EOF

  ssh-add ~/.ssh/id_ed25519
}

ask "Enter git author and commiter name" "AUTHOR_NAME"
ask "What's $(whoami) email address?" "EMAIL_ADDRESS"

echo "export EMAIL=$EMAIL_ADDRESS" >> ~/.env
echo "export GIT_AUTHOR_NAME=\"$AUTHOR_NAME\"" >> ~/.env
echo "export GIT_COMMITER_NAME=\"$AUTHOR_NAME\"" >> ~/.env
echo "export GIT_AUTHOR_EMAIL=$EMAIL_ADDRESS" >> ~/.env
echo "export GIT_COMMITER_EMAIL=$EMAIL_ADDRESS" >> ~/.env

# setting up folders
mkdir -p ~/dev
mkdir -p ~/.ssh

# link dotfiles
./link.sh

xcode-select --install

ask "Would you like to setup homebrew on this user?" "SETUP_HOMEBREW"

<<<<<<< HEAD
if [ "$SETUP_HOMEBREW" = "y" ] ; then
  setup_homebrew
fi
=======
#set brew to all administrators
sudo chgrp -R administrators $(brew --prefix)/* # give brew to admins
sudo chgrp -R administrators /usr/local/Cellar/*
sudo chgrp -R administrators /usr/local/Cellar/
sudo chmod -R g+w $(brew --prefix)/* # let group write
sudo chmod -R g+w /usr/local/Cellar/*
sudo chmod -R g+w /usr/local/Cellar/

echo "Installing applications (this may take a while)..."
brew doctor
brew bundle
brew upgrade
>>>>>>> f6866d0 (this)

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

ask "Gen ssh keys? [y/n]" "GEN_KEYS"

# setting up secrets
if [ "$GEN_KEYS" = "y" ] ; then
  gen_keys
fi

echo "All done, reload the terminal."
