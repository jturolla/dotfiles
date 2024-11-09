
mkdir -p ~/.config/nix-darwin
mkdir -p ~/.config/home-manager

ln -svf $DOTFILES/nix/flake.nix ~/.config/nix-darwin/flake.nix
ln -svf $DOTFILES/nix/home.nix  ~/.config/home-manager/home.nix
