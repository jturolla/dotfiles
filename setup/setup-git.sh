#!/bin/bash

setup_git_config() {
    echo "Setting up Git..."
    if [ ! -f ~/.personalgitconfig ]; then
        cp gitconfig-template ~/.personalgitconfig
        if [ -n "${GIT_NAME:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
            sed -i.bak "s/GITNAME/$GIT_NAME/g" ~/.personalgitconfig
            sed -i.bak "s/GITEMAIL/$GIT_EMAIL/g" ~/.personalgitconfig
            rm -f ~/.personalgitconfig.bak
        fi
    fi
    if [ ! -f ~/.nugitconfig ]; then
        cp gitconfig-template ~/.nugitconfig
    fi
}

main() {
    setup_git_config
    setup_github_keys
}

main