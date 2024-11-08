#!/bin/bash


mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
