
mkdir -p ~/.config/nix-darwin
mkdir -p ~/.config/home-manager
mkdir -p ~/.config/nix/

ln -svf $DOTFILES/nix/flake.nix ~/.config/nix-darwin/flake.nix
ln -svf $DOTFILES/nix/home.nix  ~/.config/home-manager/home.nix
ln -svf $DOTFILES/nix/nix.conf  ~/.config/nix/nix.conf
