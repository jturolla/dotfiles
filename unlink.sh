#!/usr/bin/env bash
set -euo pipefail

# List of dotfiles symlinks to remove
files=(
  "$HOME/.vimrc"
  "$HOME/.tmux.conf"
  "$HOME/.gitignore"
  "$HOME/.gitconfig"
  "$HOME/.bash_profile"
  "$HOME/.zshrc"
  "$HOME/.ssh/config"
)

for file in "${files[@]}"; do
  if [ -L "$file" ]; then
    unlink "$file"
    echo "Unlinked $file"
  else
    echo "Skipping $file (not a symlink)"
  fi
done
