{
  description = "Julio's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ...}:
  let
    configuration = { pkgs, ... }: {

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # Core Basic Tools
          # pkgs.bash already installed somewhere else
          pkgs.wget
          pkgs.git
          pkgs.jq
          pkgs.yq
          pkgs.rename
          pkgs.htop
          pkgs.less
          pkgs.tree
          pkgs.watch

          # Languages
          pkgs.nodejs
          pkgs.perl
          pkgs.go
          pkgs.python3
          pkgs.ruby
          pkgs.cargo
          pkgs.clojure

          # Utils
          pkgs.findutils # GNU find, locate, updatedb, and xargs
          pkgs.coreutils # GNU core utilities
          pkgs.moreutils  # Additional Unix utilities, eg. sponge

          # Vendor Services Tools
          pkgs.github-cli

          # Terminal Tools
          pkgs.reattach-to-user-namespace
          pkgs.fzf
          pkgs.ripgrep
          pkgs.tmux

          # Editors
          pkgs.vim
          pkgs.neovim

          # Text Tools
          pkgs.diff-so-fancy
          pkgs.colordiff
          pkgs.diffutils

          # Container Tools
          pkgs.docker
          pkgs.colima # Docker VM, use `colima start` to start it.

          # Kubernetes tools
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kustomize
          pkgs.ko

          # Networking Tools
          pkgs.ipcalc
          pkgs.mtr
          pkgs.nmap
          pkgs.nload
          pkgs.ldns # git is depending on it, but why?
          pkgs.tcpdump
          pkgs.iftop

          # Image Tools
          pkgs.exiftool
          pkgs.imagemagick
          pkgs.ffmpeg

          # Fun & Reference
          pkgs.cmatrix
          pkgs.neofetch
          pkgs.tldr

          # Apps
          pkgs.slack
        ];

      homebrew = {
        enable = true;

        brews = [
          "deno"
          "mas"
          "youtube-dl"
        ];

        casks = [
          # apps
          "arc"
          "bartender"
          "beeper"
          "chatgpt"
          "discord"
          "iina"
          "intellij-idea"
          "iterm2"
          "istat-menus"
          "logseq"
          "raycast"
          "roam-research"
          "slack"
          "spotify"
          "the-unarchiver"
          "visual-studio-code"
        ];

        masApps = {
          "Parcel" = 639968404;
          "Things 3" = 904280696;
          "Yoink" = 457622435;
        };

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # Allow installing unfree packages (like Slack)
      nixpkgs.config.allowUnfree = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.bash.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      #81 defaults write com.apple.dock persistent-apps x
      #82 defaults write -g ApplePressAndHoldEnabled -bool false
      #83 defaults write NSGlobalDomain KeyRepeat -int 1
      #84 defaults write NSGlobalDomain InitialKeyRepeat -int 12
      #85 defaults write -g com.apple.mouse.scaling -float 10.0

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."ju-mb-air" = nix-darwin.lib.darwinSystem {
      modules = [ configuration
        home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jturolla = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."ju-mb-air".pkgs;
  };
}
