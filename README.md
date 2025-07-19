# Dotfiles

Personal dotfiles for macOS and Linux environments with a robust, colorful setup system.

## Features

- 🎨 **Colorful setup experience** with clear progress indicators
- 🔒 **Robust error handling** with `set -euo pipefail` guardrails
- 🔄 **Idempotent setup** - run multiple times safely
- 🛠️ **Modular scripts** - each component works independently
- ✅ **Built-in validation** and verification
- 📦 **Makefile integration** with shellcheck linting
- 🔧 **Automatic backups** of existing configurations
- 🌍 **Cross-platform support** for macOS and Linux

## Quick Start

1. **Clone and setup:**
   ```bash
   git clone https://github.com/jturolla/dotfiles.git ~/dev/dotfiles
   cd ~/dev/dotfiles
   cp setup/.setupconf.template .setupconf
   # Edit .setupconf with your preferences
   make setup
   ```

2. **Or use the all-in-one setup:**
   ```bash
   ./setup.sh
   ```

## Available Commands

Run `make help` to see all available commands:

### Setup Commands
- `make setup` - Run the complete dotfiles setup
- `make setup-test` - Run setup with test configuration  
- `make setup-darwin` - Run macOS-specific setup only
- `make setup-linux` - Run Linux-specific setup only
- `make setup-1password-ssh` - Enable SSH from 1Password (run after main setup)

### Development Commands
- `make lint` - Run shellcheck on all shell scripts (installs shellcheck if needed)
- `make lint-if-available` - Run shellcheck only if already installed
- `make fix-permissions` - Fix permissions on shell scripts
- `make validate-env` - Validate environment and dependencies

### Utility Commands
- `make clean` - Clean temporary files and directories
- `make backup` - Create a backup of current configurations
- `make unlink` - Unlink all dotfiles

## Configuration

Copy `setup/.setupconf.template` to `.setupconf` and customize:

```bash
# Git configuration
GIT_NAME="Your Name"
GIT_EMAIL="your.email@example.com"

# GitHub username for SSH key setup (Linux only)
GITHUB_USER="your-github-username"

# Package management
SKIP_BREW="false"
EXTRA_PACKAGES="package1 package2"

# Application settings
VIM_COLORSCHEME="monokai"
LOG_LEVEL="INFO"

# Skip specific setup steps
SKIP_FONTS="false"
SKIP_VIM="false"
SKIP_GIT="false"
```

## What Gets Installed

### macOS (via Homebrew)
- Development tools and languages (Go, Node.js, Python, etc.)
- CLI utilities (fzf, ripgrep, jq, etc.)
- Applications from Brewfile

### Linux (via apt)
- Essential packages and build tools
- Development languages and runtimes
- Docker and container tools
- AWS CLI v2
- Kubernetes tools

### All Platforms
- Powerline fonts for terminal
- Vim with vim-plug and plugins
- Git configuration templates
- SSH configuration
- Custom shell configurations

## Individual Script Usage

Each setup script can be run independently:

```bash
# Run specific setup components
cd setup
./setup-config.sh      # Load and validate configuration
./setup-link.sh        # Link dotfiles
./setup-darwin.sh      # macOS-specific setup
./setup-linux.sh       # Linux-specific setup  
./setup-git.sh         # Git configuration
./setup-vim.sh         # Vim setup
./setup-fonts.sh       # Font installation
```

## 1Password SSH Integration

For enhanced security on macOS, set up 1Password SSH agent after main setup:

```bash
make setup-1password-ssh
```

This configures SSH to use 1Password as the SSH agent, providing secure key management. The script will:
- Detect if 1Password is installed
- Configure SSH to use 1Password's SSH agent
- Provide helpful setup instructions
- Gracefully handle missing installations

## Safety Features

- ✅ **Automatic backups** - Existing files are backed up before modification
- 🔍 **Validation checks** - Configuration and dependencies are validated
- 🛡️ **Error handling** - Scripts fail fast with clear error messages  
- 🔄 **Idempotent** - Safe to run multiple times
- 📊 **Progress tracking** - Clear visual progress indicators
- 🧪 **Test mode** - `make setup-test` uses test configuration

## Customization

### Adding New Packages

**macOS**: Add to `Brewfile`
```ruby
brew "new-package"
cask "new-application"
```

**Linux**: Add to `EXTRA_PACKAGES` in `.setupconf`
```bash
EXTRA_PACKAGES="package1 package2 new-package"
```

### Extending Setup

Create new setup scripts in the `setup/` directory following the pattern:
- Include proper error handling with `set -euo pipefail`
- Source utilities: `source "$DOTFILES_ROOT/lib/setup-utils.sh"`
- Use logging functions: `log_info`, `log_success`, `log_warning`, `log_error`
- Make scripts work independently and as part of main setup

## Development

### Linting
The Makefile provides multiple linting options:

```bash
make install-shellcheck  # Install shellcheck (supports multiple package managers)
make lint                # Run shellcheck (auto-installs if possible)
make lint-if-available   # Run shellcheck only if already installed
```

**Supported package managers for shellcheck:**
- Homebrew (macOS)
- apt-get (Debian/Ubuntu)
- yum (RHEL/CentOS)
- dnf (Fedora)
- pacman (Arch Linux)

### Testing
```bash
make setup-test          # Run with test configuration
make validate-env        # Validate environment
```

## Troubleshooting

### Common Issues

**Scripts not executable:**
```bash
make fix-permissions
```

**Configuration issues:**
```bash
make validate-env
```

**Linting without package manager:**
```bash
make lint-if-available   # Gracefully skips if shellcheck not available
```

**1Password SSH setup fails:**
- Script detects missing 1Password and provides installation instructions
- Allows continuation for manual setup
- Provides detailed next steps

**Setup failures:**
- Check `.setupconf` configuration
- Run individual scripts for detailed error output
- Use `--debug` flag for verbose logging

### Getting Help

1. Run `make help` for available commands
2. Check individual script help: `./setup.sh --help`
3. Review logs for specific error messages
4. Use `make lint-if-available` for optional linting
5. Ensure all required dependencies are installed

### Manual Installation

If package managers aren't available:

**shellcheck**: Download from [GitHub releases](https://github.com/koalaman/shellcheck)

**1Password**: Download from [1password.com](https://1password.com/downloads/)

## License

MIT License - see LICENSE file for details.
