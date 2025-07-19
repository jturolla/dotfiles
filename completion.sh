#!/bin/bash

# Bash Completion Configuration
# Loads completion for various tools using system packages and dynamic generation

# Enable programmable completion features
if ! shopt -oq posix; then
  # Linux/Ubuntu completion
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  
  # macOS Homebrew completion
  if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  fi
fi

# Git completion (usually comes with git package or bash-completion)
# On macOS with Homebrew: brew install bash-completion
# On Linux: apt install bash-completion

# Custom completions
if [ -f "$DOTFILES/lib/win-completion.bash" ]; then
  . "$DOTFILES/lib/win-completion.bash"
fi

# Dynamic completions (generated on-the-fly)
# kubectl completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
fi

# GitHub CLI completion
if command -v gh >/dev/null 2>&1; then
  source <(gh completion -s bash)
fi

# kustomize completion (generate dynamically instead of static file)
if command -v kustomize >/dev/null 2>&1; then
  source <(kustomize completion bash)
fi

# AWS CLI completion
if command -v aws_completer >/dev/null 2>&1; then
  complete -C aws_completer aws
elif [ -f '/opt/homebrew/bin/aws_completer' ]; then
  complete -C '/opt/homebrew/bin/aws_completer' aws
fi

# fzf completion and key bindings
if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash
elif [ -f "/opt/homebrew/opt/fzf/shell/completion.bash" ]; then
  source "/opt/homebrew/opt/fzf/shell/completion.bash"
  source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
fi

# Docker completion (if installed via package manager)
if [ -f /etc/bash_completion.d/docker ]; then
  . /etc/bash_completion.d/docker
fi
