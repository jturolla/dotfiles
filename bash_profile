#!/bin/bash

# Bash Profile Configuration
# Main entry point for shell customization

# Enable vi editing mode
set editing-mode vi

# Set dotfiles directory
export DOTFILES=$HOME/dev/dotfiles

# Core shell configuration (order matters)
source $DOTFILES/env.sh          # Environment variables
source $DOTFILES/path.sh         # PATH configuration
source $DOTFILES/colors.sh       # Color definitions
source $DOTFILES/aliases.sh      # Command aliases
source $DOTFILES/prompt.sh       # PS1 prompt configuration
source $DOTFILES/history.sh      # History settings
source $DOTFILES/completion.sh   # Completion for all tools

# External configuration files
# Private environment variables (not tracked in git)
[ -f "$HOME/.env" ] && source "$HOME/.env"

# Work-related configuration (not tracked in git)
[ -f "$HOME/.nurc" ] && source "$HOME/.nurc"
