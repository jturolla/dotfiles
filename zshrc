#!/bin/zsh

# Zsh configuration that loads the same setup as bash_profile
# but excludes prompt configuration as requested

# Set vi editing mode
set -o vi

export DOTFILES=$HOME/dev/dotfiles

# Load environment variables
source $DOTFILES/env.sh

# Load path configuration
source $DOTFILES/path.sh

# Load aliases with zsh-specific adjustments
source $DOTFILES/aliases.sh

# Update the reload alias for zsh
alias reload!="source ~/.zshrc; echo 'Reloaded!'"

# Load colors
source $DOTFILES/colors.sh

# Load history configuration (adapted for zsh)
export HISTSIZE=5000000
export SAVEHIST=100000000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Private Env
[ -f "$HOME/.env" ] && source "$HOME/.env"

# Work related
[ -f "$HOME/.nurc" ] && source "$HOME/.nurc"

# Zsh completion system
autoload -Uz compinit
compinit

# Load homebrew completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Enable kubectl completion if available
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Enable gh completion if available
if command -v gh >/dev/null 2>&1; then
  source <(gh completion -s zsh)
fi

# Enable fzf completion and key bindings if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
fi

# Load custom completions adapted for zsh
# Note: Git completion is built into zsh
# For kustomize and other custom completions, you may need to generate zsh versions

# Enable kustomize completion if available
if command -v kustomize >/dev/null 2>&1; then
  source <(kustomize completion zsh)
fi

## The following lines should be empty... but sometimes a program writes here :)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
