#/bin/sh

# Install NIx
sh <(curl -L https://nixos.org/nix/install)

# Create default Nix Darwin Configuration under ~/.config/nix-darwin 
# nix run nix-darwin -- switch --flake ~/.config/nix-darwin

# Install Nix Darwin
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix-darwin --impure
