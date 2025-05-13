#!/bin/bash

install_packages() {
    # Install gpg and snapd first
    sudo apt-get update
    sudo apt-get install -y gpg snapd

    # Add necessary repositories
    echo "Adding required repositories..."

    # Add Kubernetes repository
    sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Update package list and install unzip first
    sudo apt-get update
    sudo apt-get install -y unzip

    # Install AWS CLI v2
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip

    # Install yq using snap
    echo "Installing yq using snap..."
    sudo snap install yq || echo "Failed to install yq via snap, skipping..."

    # Install essential packages
    echo "Installing essential packages..."
    sudo apt-get update
    # Try to install each package individually to handle failures gracefully
    PACKAGES=(
        automake
        bash
        bash-completion
        binutils
        build-essential
        clojure
        colordiff
        coreutils
        curl
        diffutils
        findutils
        fzf
        gawk
        gettext
        gh
        git
        git-lfs
        golang
        grep
        gzip
        htop
        iftop
        imagemagick
        ipcalc
        iperf
        jq
        kubectl
        less
        moreutils
        mtr
        nload
        nmap
        nodejs
        npm
        openjdk-17-jdk
        openssh-server
        perl
        python3
        python3-pip
        r-base
        rclone
        rename
        ripgrep
        rsync
        rust-all
        s3cmd
        telnet
        tmux
        tree
        unzip
        vim
        watch
        wdiff
        wget
        xmlstarlet
    )

    for package in "${PACKAGES[@]}"; do
        echo "Installing $package..."
        sudo apt-get install -y "$package" || echo "Failed to install $package, skipping..."
    done

    if [ -n "${EXTRA_PACKAGES:-}" ]; then
        for package in $EXTRA_PACKAGES; do
            echo "Installing extra package $package..."
            sudo apt-get install -y "$package" || echo "Failed to install $package, skipping..."
        done
    fi

    # Install additional tools that need special handling
}

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

setup_docker() {
    echo "Setting up Docker..."
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "Docker installed. Please log out and back in for docker group changes to take effect."
}


main() {
    echo "Setting up Linux environment..."
    install_packages
    setup_ssh_server
    setup_docker
}

main