#!/bin/bash

###############################################################################
# Linux Setup Script
# Sets up Linux-specific environment and packages
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Linux Environment Setup"

check_linux_requirements() {
    log_step "Checking Linux requirements"
    
    if ! is_linux; then
        fail_fast "This script is only for Linux systems"
    fi
    
    local distro
    distro=$(get_linux_distro)
    log_info "Detected Linux distribution: $distro"
    
    if [[ "$distro" != "ubuntu" && "$distro" != "debian" ]]; then
        log_warning "This script is optimized for Ubuntu/Debian systems"
        log_warning "Some packages may not install correctly on $distro"
    fi
    
    log_success "Linux system requirements checked"
}

update_package_manager() {
    log_step "Updating package manager"
    
    log_info "Updating apt package lists"
    sudo apt-get update || fail_fast "Failed to update package lists"
    
    log_success "Package manager updated"
}

install_essential_packages() {
    log_step "Installing essential packages"
    
    # Install essential packages first
    local essential_packages=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "unzip"
    )
    
    for package in "${essential_packages[@]}"; do
        if ! package_installed "$package"; then
            log_info "Installing essential package: $package"
            sudo apt-get install -y "$package" || log_warning "Failed to install $package"
        else
            log_debug "Essential package already installed: $package"
        fi
    done
    
    log_success "Essential packages installation completed"
}

add_repositories() {
    log_step "Adding required repositories"
    
    # Add Kubernetes repository
    log_info "Adding Kubernetes repository"
    if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        log_success "Kubernetes repository added"
    else
        log_info "Kubernetes repository already configured"
    fi
    
    # Update package lists after adding repositories
    sudo apt-get update || log_warning "Failed to update package lists after adding repositories"
    
    log_success "Repository setup completed"
}

install_aws_cli() {
    log_step "Installing AWS CLI v2"
    
    if command_exists aws; then
        local aws_version
        aws_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        log_info "AWS CLI is already installed (version: $aws_version)"
        return 0
    fi
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    log_info "Downloading AWS CLI v2"
    if download_file "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "$temp_dir/awscliv2.zip"; then
        (cd "$temp_dir" && unzip -q awscliv2.zip)
        sudo "$temp_dir/aws/install" || log_warning "AWS CLI installation may have failed"
        rm -rf "$temp_dir"
        
        if command_exists aws; then
            log_success "AWS CLI v2 installed successfully"
        else
            log_warning "AWS CLI installation completed but command not found in PATH"
        fi
    else
        log_warning "Failed to download AWS CLI v2"
    fi
}

install_snap_packages() {
    log_step "Installing snap packages"
    
    # Install snapd if not present
    if ! command_exists snap; then
        log_info "Installing snapd"
        sudo apt-get install -y snapd || log_warning "Failed to install snapd"
    fi
    
    if command_exists snap; then
        # Install yq using snap
        log_info "Installing yq via snap"
        sudo snap install yq || log_warning "Failed to install yq via snap"
    else
        log_warning "Snap not available, skipping snap packages"
    fi
    
    log_success "Snap packages installation completed"
}

install_main_packages() {
    log_step "Installing main packages"
    
    # Define packages to install
    local packages=(
        "automake"
        "bash"
        "bash-completion"
        "binutils"
        "clojure"
        "colordiff"
        "coreutils"
        "diffutils"
        "findutils"
        "fzf"
        "gawk"
        "gettext"
        "gh"
        "git-lfs"
        "golang"
        "grep"
        "gzip"
        "htop"
        "iftop"
        "imagemagick"
        "ipcalc"
        "iperf"
        "jq"
        "kubectl"
        "less"
        "moreutils"
        "mtr"
        "nload"
        "nmap"
        "nodejs"
        "npm"
        "openjdk-17-jdk"
        "openssh-server"
        "perl"
        "python3"
        "python3-pip"
        "r-base"
        "rclone"
        "rename"
        "ripgrep"
        "rsync"
        "rust-all"
        "s3cmd"
        "telnet"
        "tmux"
        "tree"
        "unzip"
        "vim"
        "watch"
        "wdiff"
        "wget"
        "xmlstarlet"
    )
    
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        if ! package_installed "$package"; then
            log_info "Installing package: $package"
            if sudo apt-get install -y "$package"; then
                log_debug "Successfully installed: $package"
            else
                log_warning "Failed to install: $package"
                failed_packages+=("$package")
            fi
        else
            log_debug "Package already installed: $package"
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warning "Some packages failed to install:"
        for package in "${failed_packages[@]}"; do
            log_warning "  - $package"
        done
    fi
    
    log_success "Main packages installation completed"
}

install_extra_packages() {
    if [[ -n "${EXTRA_PACKAGES:-}" ]]; then
        log_step "Installing extra packages: $EXTRA_PACKAGES"
        
        for package in $EXTRA_PACKAGES; do
            log_info "Installing extra package: $package"
            sudo apt-get install -y "$package" || log_warning "Failed to install $package"
        done
        
        log_success "Extra packages installation completed"
    fi
}

setup_ssh_server() {
    log_step "Setting up SSH server"
    
    if systemctl is-active --quiet ssh; then
        log_info "SSH server is already active"
        return 0
    fi
    
    log_info "SSH server is not active. Starting SSH service"
    
    # Ensure openssh-server is installed
    if ! package_installed openssh-server; then
        log_info "Installing openssh-server"
        sudo apt-get install -y openssh-server || fail_fast "Failed to install openssh-server"
    fi
    
    # Enable and start SSH service
    sudo systemctl enable ssh || log_warning "Failed to enable SSH service"
    sudo systemctl start ssh || log_warning "Failed to start SSH service"
    
    if systemctl is-active --quiet ssh; then
        log_success "SSH server is now active"
    else
        log_warning "SSH server may not be running properly"
    fi
}

setup_docker() {
    log_step "Setting up Docker"
    
    if command_exists docker; then
        log_info "Docker is already installed"
        return 0
    fi
    
    log_info "Installing Docker"
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi
    
    # Set up the repository
    local arch
    arch=$(dpkg --print-architecture)
    local codename
    codename=$(lsb_release -cs)
    
    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $codename stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package list
    sudo apt-get update
    
    # Install Docker Engine
    local docker_packages=(
        "docker-ce"
        "docker-ce-cli"
        "containerd.io"
        "docker-compose-plugin"
    )
    
    for package in "${docker_packages[@]}"; do
        log_info "Installing Docker package: $package"
        sudo apt-get install -y "$package" || log_warning "Failed to install $package"
    done
    
    # Add current user to docker group
    if ! groups "$USER" | grep -q docker; then
        log_info "Adding user $USER to docker group"
        sudo usermod -aG docker "$USER"
        log_info "Please log out and back in for docker group changes to take effect"
    else
        log_info "User $USER is already in docker group"
    fi
    
    if command_exists docker; then
        log_success "Docker installation completed"
    else
        log_warning "Docker installation may have failed"
    fi
}

main() {
    check_linux_requirements
    update_package_manager
    install_essential_packages
    add_repositories
    install_aws_cli
    install_snap_packages
    install_main_packages
    install_extra_packages
    setup_ssh_server
    setup_docker
    
    print_footer "Linux setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi