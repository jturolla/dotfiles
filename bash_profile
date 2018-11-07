#!/bin/bash

export DOTFILES=$HOME/dev/dotfiles

source $DOTFILES/env.sh
source $DOTFILES/path.sh
source $DOTFILES/prompt.sh
source $DOTFILES/aliases.sh
source $DOTFILES/colors.sh
source $DOTFILES/completion.sh
source $DOTFILES/docker-aliases.sh

source $HOME/.env

if [ -f ~/.nurc ]; then
  source $HOME/.nurc
  export NUCLI_HOME="$HOME/dev/nu/nucli"
  export NU_HOME="$HOME/dev/nu"
fi

source $HOME/dev/jturolla/deq/deq.sh

export PATH="$HOME/.cargo/bin:$PATH"
