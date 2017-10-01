#!/bin/bash

export DOTFILES=$HOME/dotfiles

. $DOTFILES/env.sh
. $DOTFILES/prompt.sh
. $DOTFILES/path.sh
. $DOTFILES/aliases.sh
. $DOTFILES/colors.sh
. $DOTFILES/completion.sh
. $DOTFILES/docker-aliases.sh

source $HOME/.nurc
