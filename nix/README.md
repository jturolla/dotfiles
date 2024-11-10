# Nix Configuration

1. Install Nix
2. Configure the nix darwin
3. Restart shell

Switching to the env defined in the flake:
```
darwin-rebuild switch --flake flake.nix
```

Finding a nix package:
```
nix search
```

Locking the nix flake:

```
nix flake lock
```


# Home Manager

Install home manager standalone:
```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```
