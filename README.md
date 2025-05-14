# Dotfiles

System configuration files and setup scripts for macOS and Linux systems. Includes configurations for bash, vim, tmux, git, and other development tools.

## Features

- Works on macOS and Linux
- Automated setup process
- Package management with Homebrew (macOS)
- Custom shell prompt with git and kubernetes info
- Vim configuration and plugins
- iTerm2 color schemes
- Tmux configuration
- SSH agent integration with 1Password
- Git configuration with multiple profiles

## Requirements

macOS:
- Xcode Command Line Tools
- Homebrew
- 1Password (for SSH)

Linux:
- Build tools
- OpenSSH server

## Installation

1. Clone the repository:
```bash
git clone https://github.com/jturolla/dotfiles.git ~/dev/dotfiles
```

2. Run setup:
```bash
cd ~/dev/dotfiles
./setup.sh
```

The setup will:
- Install required packages
- Create directories
- Set up configuration files
- Configure development tools
- Install Vim plugins

## Main Configuration Files

- `bash_profile`: Main shell settings
- `aliases.sh`: Command shortcuts
- `env.sh`: Environment variables
- `path.sh`: PATH settings
- `prompt.sh`: Shell prompt customization
- `colors.sh`: Terminal colors
- `completion.sh`: Command completion
- `history.sh`: Shell history
- `vimrc`: Vim settings
- `tmux.conf`: Tmux settings
- `gitconfig`: Git settings
- `ssh_config`: SSH settings

## Package Management

The `Brewfile` includes common development tools:
- Git, Vim, Tmux
- AWS and Kubernetes CLI
- System tools (htop, tree, ripgrep)
- Applications (iTerm2, VS Code, Docker)

## Customization

### Git Setup
Two profile options:
- Personal: `~/.personalgitconfig`
- Work: `~/.nugitconfig`

Update these files with your information after install.

### Shell Prompt
Shows:
- Username
- Current directory
- Git branch
- Kubernetes context
- Command status

### Vim Settings
Includes:
- Plugin manager (vim-plug)
- Custom keys
- Code formatting
- File browser (NERDTree)

### Tmux Settings
Features:
- Ctrl+a prefix key
- Window management shortcuts
- Mouse support
- Status bar
- Copy/paste settings

## Scripts

The `bin` directory has utility scripts:
- `set-hostname`: Change system hostname
- `win`: Create tmux windows with splits

## Removal

To remove configurations:
```bash
./unlink.sh
```

## License

See LICENSE file in repository.

## Contributing

Contributions welcome through Pull Requests.
