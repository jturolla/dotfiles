# Dotfiles

A comprehensive collection of dotfiles and system configuration for macOS and Linux environments, featuring customized configurations for bash, vim, tmux, git, and more.

## Features

- 🚀 Cross-platform support (macOS and Linux)
- 🔧 Automated setup scripts
- 📦 Homebrew package management (macOS)
- 🎨 Custom prompt with git and kubernetes context information
- ⌨️  Vim configuration with plugins
- 🖥️  iTerm2 color schemes
- 🔄 Tmux configuration with custom keybindings
- 🔑 1Password SSH agent integration
- 🐙 Git configuration with multiple profile support

## Prerequisites

- For macOS:
  - Xcode Command Line Tools
  - [Homebrew](https://brew.sh)
  - [1Password](https://1password.com) (for SSH agent)
- For Linux:
  - Basic build tools
  - OpenSSH server

## Installation

1. Clone the repository:
```bash
git clone https://github.com/jturolla/dotfiles.git ~/dev/dotfiles
```

2. Run the setup script:
```bash
cd ~/dev/dotfiles
./setup.sh
```

The setup script will:
- Install required packages via Homebrew (macOS) or apt (Linux)
- Create necessary directories
- Set up symbolic links for configuration files
- Configure git, vim, and tmux
- Set up SSH configuration
- Install Vim plugins

## Configuration Files

- `bash_profile`: Main bash configuration file
- `aliases.sh`: Custom shell aliases
- `env.sh`: Environment variables
- `path.sh`: PATH configuration
- `prompt.sh`: Custom shell prompt with git and kubernetes info
- `colors.sh`: Terminal color settings
- `completion.sh`: Command completion settings
- `history.sh`: Shell history configuration
- `vimrc`: Vim editor configuration
- `tmux.conf`: Tmux terminal multiplexer settings
- `gitconfig`: Git configuration
- `ssh_config`: SSH client configuration

## Homebrew Packages (macOS)

The `Brewfile` includes a curated selection of useful tools and applications:

- Development tools (git, vim, tmux)
- Cloud tools (aws-cli, kubernetes-cli)
- System utilities (htop, tree, ripgrep)
- Applications (iTerm2, Visual Studio Code, Docker)

## Customization

### Git Configuration

The setup supports multiple Git profiles through the following files:
- `~/.personalgitconfig`: Personal Git configuration
- `~/.nugitconfig`: Work-related Git configuration

Edit these files with your information after installation.

### Shell Prompt

The custom prompt (`prompt.sh`) displays:
- Current user
- Working directory
- Git branch
- Kubernetes context and namespace
- Exit status of last command

### Vim Configuration

The `vimrc` includes:
- Plugin management with vim-plug
- Custom keybindings
- Code formatting settings
- File type specific configurations
- NERDTree file explorer

### Tmux Configuration

The `tmux.conf` includes:
- Custom prefix (Ctrl+a)
- Pane management shortcuts
- Mouse support
- Status bar customization
- Copy/paste integration

## Utility Scripts

The `bin/` directory contains useful scripts:
- `set-hostname`: Set system hostname
- `win`: Create new tmux window with split panes

## Uninstalling

To remove the dotfiles configuration:

```bash
./unlink.sh
```

This will remove all symbolic links created during setup.

## License

This project is licensed under the terms of the LICENSE file included in the repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
