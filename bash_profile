#!/bin/bash

export DOTFILES=$HOME/dev/dotfiles

source $DOTFILES/env.sh
source $DOTFILES/path.sh
source $DOTFILES/prompt.sh
source $DOTFILES/aliases.sh
source $DOTFILES/colors.sh
source $DOTFILES/completion.sh
source $DOTFILES/history.sh

# Private Env
[ -f ~/.env ] && source $HOME/.env

# Work related
[ -f ~/.nurc ] && source $HOME/.nurc

#eval "$(rbenv init -)"

# Setup fzf finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash


if [ "$(uname)" == "Darwin" ]; then
  source $DOTFILES/macos.sh
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  source $DOTFILES/linux.sh
  alias gsed=sed
fi

## The following lines should be empty... but sometimes a program writes here :)
