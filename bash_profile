#!/bin/bash

export DOTFILES=$HOME/dev/dotfiles

. $DOTFILES/env.sh
. $DOTFILES/path.sh
. $DOTFILES/prompt.sh
. $DOTFILES/aliases.sh
. $DOTFILES/colors.sh
. $DOTFILES/completion.sh
. $DOTFILES/docker-aliases.sh

. $HOME/.nurc
