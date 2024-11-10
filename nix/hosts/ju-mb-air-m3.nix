{ self, config, pkgs, lib, ... }:
let 
  username = "jturolla";
in 
{
  imports = [];

  home = {
    inherit username;
    homeDirectory = lib.mkForce("/Users/${username}");

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

 # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}



# { pkgs, config, self, ... }:
# let
#   username = "username";
# in
# {
#   imports = [
#     ../../home-manager/common.nix
#     ../../configurations/overlays.nix
#     ../../home-manager/programs/zsh.nix
#   ];

#   home = {
#     inherit username;
#     homeDirectory = "/home/${username}";
#     sessionVariables = {
#       DOTFILES = "$HOME/.dotfiles";
#       NIXOS_OZONE_WL = "1";
#     };
#   };
# }