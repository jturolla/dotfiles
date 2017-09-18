#!/bin/bash

export DOTFILES=$HOME/dotfiles

. $DOTFILES/env.sh
. $DOTFILES/prompt.sh
. $DOTFILES/path.sh
. $DOTFILES/aliases.sh
. $DOTFILES/colors.sh
. $DOTFILES/completion.sh

source $HOME/.nurc

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
