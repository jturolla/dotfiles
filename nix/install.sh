#/bin/bash

DOTFILES="$HOME/dev/dotfiles"

# Install NIx
sh <(curl -L https://nixos.org/nix/install)

# Create ~/dev if not exists
mkdir -p ~/dev

#  Clone dotfiles
nix-shell -p git --run "git clone git@github.com:jturolla/dotfiles.git ~/dev/"

ln -svf $DOTFILES/nix/nix.conf  ~/.config/nix/nix.conf

# Create nix-darwin folder and link flake.nix
mkdir -p ~/.config/nix-darwin
ln -svf $DOTFILES/nix/flake.nix ~/.config/nix-darwin/flake.nix

# Install Nix Darwin
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix-darwin --impure

#The binary `switch` is available in the path (at dotfiles/bin) to enable the verison
