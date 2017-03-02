#!/bin/bash

tmux start-server
tmux attach-session -t ju 2> /dev/null | tmux new-session -d -s ju

tmux new-window -t ju:2 -n parafuzo  'cd ~/projects/parafuzo/'
tmux new-window -t ju:3 -n dotfiles  'cd ~/dotfiles'

tmux split-window -t ju:1
tmux split-window -t ju:2
tmux split-window -t ju:3
