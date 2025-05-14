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

setup_github_keys() {
    # Only download keys on Linux, as macOS uses 1Password
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Setting up GitHub authorized keys..."
        if [ -n "${GITHUB_USER:-}" ]; then
            mkdir -p ~/.ssh
            curl -s "https://github.com/${GITHUB_USER}.keys" > ~/.ssh/authorized_keys
            chmod 600 ~/.ssh/authorized_keys
            echo "Downloaded authorized keys from GitHub user ${GITHUB_USER}"
        else
            echo "GITHUB_USER not set, skipping authorized keys setup"
        fi
    fi
}

main() {
    setup_git_config
    setup_github_keys
}

main