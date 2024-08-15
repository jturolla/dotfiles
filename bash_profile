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
source $HOME/.env

# Work related
source $HOME/.nurc

## The following lines should be empty... but sometimes a program writes here :)
