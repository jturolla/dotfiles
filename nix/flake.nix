{
  description = "Julio's Multihost System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # imports = [
  #   ./hosts/ju-mb-air.nix
  # ];

  # Multi host examples:
  # https://github.com/Baitinq/nixos-config/blob/master/flake.nix

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ...}:
  let
    imports = [
      ./apple.nix
    ];
    configuration = { pkgs, ... }: {

      # Enable nix-command and flakes experimental features
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      environment.variables = {
        EDITOR = "vim";
      };

      environment.systemPackages =
        [
          # Core Basic Tools
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
          pkgs.findutils  # GNU find, locate, updatedb, and xargs
          pkgs.coreutils  # GNU core utilities
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
          "gnu-sed"
          "mas"
          "pam-reattach"
          "bash"
        ];

        casks = [
          # apps
          # "visual-studio-code"
          # "spotify"
          # "iterm2"
          # "1password"
          # "arc"
          # "zoom"
          # "raycast"
          # "steam"
        ];

        masApps = {
          # "Things 3" = 904280696;
        };

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Arc.app"
          "/Applications/Things3.app"
          "/System/Applications/Notes.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/iTerm.app"
          "/System/Applications/System Settings.app"
        ];

        dock.autohide = true;

        # TODO: Accessibility - Set the mouse cursor size

        # disable hold for accent characters
        NSGlobalDomain.ApplePressAndHoldEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";

        # key repeat initial delay
        NSGlobalDomain.InitialKeyRepeat = 12;
        # key repeat speed
        NSGlobalDomain.KeyRepeat = 1;

        CustomUserPreferences = {
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
            _FXSortFoldersFirst = true;
            # When performing a search, search the current folder by default
            FXDefaultSearchScope = "SCcf";
          };
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.screensaver" = {
            # Require password immediately after sleep or screen saver begins
            askForPassword = 1;
            askForPasswordDelay = 0;
          };
          "com.apple.screencapture" = {
            location = "~/Desktop/Screenshots";
            type = "png";
          };
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
          };
          "com.apple.print.PrintingPrefs" = {
            # Automatically quit printer app once the print jobs complete
            "Quit When Finished" = true;
          };
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            # Check for software updates daily, not just once per week
            ScheduleFrequency = 1;
            # Download newly available updates in background
            AutomaticDownload = 1;
            # Install System data files & security updates
            CriticalUpdateInstall = 1;
          };
          "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
          # Prevent Photos from opening automatically when devices are plugged in
          "com.apple.ImageCapture".disableHotPlug = true;
          # Turn on app auto-update
          "com.apple.commerce".AutoUpdate = true;
        };
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # Allow installing unfree packages (like Slack)
      nixpkgs.config.allowUnfree = true;

      # Enable alternative shell support in nix-darwin.
      programs.bash.enable = true;
      programs.bash.completion.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # TODO: Enable sudo with touchid and tmux
      # https://github.com/fabianishere/pam_reattach/blob/master/include/reattach.h
      # sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

      system.activationScripts = {
        extraUserActivation = {
          text = ''
            echo "Extra user activation script..."
            "$DOTFILES"/idempotent-setup.sh
            echo "Extra user activation script... done"
          '';
          target = "rebuild";
        };
      };

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."ju-mb-air" = nix-darwin.lib.darwinSystem {
      modules = [
        # The configuration from above
        configuration

        # Homebrew
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "jturolla";
          };
        }

        # Home Manager
        home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jturolla = import ./hosts/ju-mb-air.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ];
    };

    darwinConfigurations."ju-nu-m1pro15" = nix-darwin.lib.darwinSystem {
      modules = [
        # The configuration from above
        configuration

        # Homebrew
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "julio.turolla";
          };
        }

        # Home Manager
        home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."julio.turolla" = import ./hosts/ju-nu-m1pro15.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."ju-mb-air".pkgs;
  };
}
