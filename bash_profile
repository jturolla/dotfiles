#!/bin/bash

export DOTFILES=$HOME/dev/dotfiles

source $DOTFILES/env.sh
source $DOTFILES/path.sh
source $DOTFILES/prompt.sh
source $DOTFILES/aliases.sh
source $DOTFILES/colors.sh
source $DOTFILES/completion.sh
source $DOTFILES/history.sh
#source $DOTFILES/docker-aliases.sh

source $HOME/.env

if [ -f ~/.nurc ]; then
  source $HOME/.nurc
  export NU_HOME="$HOME/dev/nu"
  export NUCLI_HOME="$NU_HOME/nucli"
fi

source $HOME/.nurc

source $HOME/dev/jturolla/deq/deq.sh

eval "$(rbenv init -)"
export GPG_TTY=$(tty)
