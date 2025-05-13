#!/bin/bash

setup_ssh_server() {
    echo "Setting up SSH server..."
    if ! systemctl is-active --quiet ssh; then
        echo "SSH server is not active. Installing and enabling..."
        sudo apt-get update
        sudo apt-get install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh
        echo "SSH server installed and started."
    else
        echo "SSH server is already active."
    fi
}

main() {
    echo "Setting up Linux environment..."
    setup_ssh_server
}

main