#/bin/sh

sh <(curl -L https://nixos.org/nix/install)
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
