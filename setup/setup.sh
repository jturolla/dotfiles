#!/bin/bash

set -euo pipefail

# Change to the parent directory of setup script
cd "$(dirname "$0")/.."

# Load configuration
source "$(dirname "$0")/setup-config.sh"


echo "Checking current shell..."
if [ "$SHELL" != "/bin/bash" ]; then
      echo "Current shell is not bash. Changing shell to bash..."
      chsh -s /bin/bash
else
      echo "Current shell is already bash. No need to change."
fi

echo "Setting up environment..."

# setting up folders
echo "Setting up folders..."
mkdir -p ~/dev
mkdir -p ~/.ssh
mkdir -p ~/Desktop/Screenshots
touch ~/.env

DOTFILES="$HOME/dev/dotfiles"

# Link dotfiles
source "$DOTFILES/setup/setup-link.sh"

# Run OS-specific setup
case "$OSTYPE" in
    darwin*)
        source "$DOTFILES/setup/setup-darwin.sh"
        ;;
    linux-gnu*)
        source "$DOTFILES/setup/setup-linux.sh"
        ;;
    *)
        echo "Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac

# Setup Vim
source "$DOTFILES/setup/setup-vim.sh"

# Setup Git
source "$DOTFILES/setup/setup-git.sh"

echo "All done! Please restart your terminal for all changes to take effect."
