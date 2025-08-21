#!/bin/bash

set editing-mode vi

export DOTFILES=$HOME/dev/dotfiles

source $DOTFILES/env.sh
source $DOTFILES/path.sh
source $DOTFILES/prompt.sh
source $DOTFILES/aliases.sh
source $DOTFILES/colors.sh
source $DOTFILES/completion.sh
source $DOTFILES/history.sh

# Private Env
[ -f "$HOME/.env" ] && source "$HOME/.env"

# Work related
[ -f "$HOME/.nurc" ] && source "$HOME/.nurc"

# Additional Homebrew completion snippets (Bash >= 4 only)
if [ "${BASH_VERSINFO:-0}" -ge 4 ]; then
    for file in /opt/homebrew/etc/bash_completion.d/*; do
        [ -r "$file" ] && source "$file"
    done
fi

## The following lines should be empty... but sometimes a program writes here :)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
