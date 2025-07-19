#!/bin/bash

###############################################################################
# Git Setup Script
# Configures Git settings and SSH keys
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Git Configuration Setup"

check_git_installation() {
    log_step "Checking Git installation"
    
    if ! command_exists git; then
        if is_macos && command_exists brew; then
            log_info "Installing Git via Homebrew"
            brew install git || fail_fast "Failed to install Git"
        elif is_linux; then
            log_info "Installing Git via package manager"
            install_package git "Git version control"
        else
            fail_fast "Git is not installed and cannot be installed automatically"
        fi
    else
        local git_version
        git_version=$(git --version | cut -d' ' -f3)
        log_info "Git is already installed (version: $git_version)"
    fi
}

setup_git_config() {
    log_step "Setting up Git configuration"
    
    # Personal Git config
    local personal_config="$HOME/.personalgitconfig"
    local template_file="$DOTFILES_ROOT/gitconfig-template"
    
    if [[ ! -f "$personal_config" ]]; then
        if [[ -f "$template_file" ]]; then
            log_info "Creating personal Git config from template"
            cp "$template_file" "$personal_config"
            
            # Replace placeholders with actual values
            if [[ -n "${GIT_NAME:-}" && "$GIT_NAME" != "Your Name" ]]; then
                sed -i.bak "s/GITNAME/$GIT_NAME/g" "$personal_config"
                log_info "Set Git name: $GIT_NAME"
            else
                log_warning "GIT_NAME not set, please edit $personal_config manually"
            fi
            
            if [[ -n "${GIT_EMAIL:-}" && "$GIT_EMAIL" != "your.email@example.com" ]]; then
                sed -i.bak "s/GITEMAIL/$GIT_EMAIL/g" "$personal_config"
                log_info "Set Git email: $GIT_EMAIL"
            else
                log_warning "GIT_EMAIL not set, please edit $personal_config manually"
            fi
            
            # Clean up backup files
            rm -f "$personal_config.bak"
        else
            log_warning "Git config template not found: $template_file"
        fi
    else
        log_info "Personal Git config already exists: $personal_config"
    fi
    
    # Nu Git config (for work)
    local nu_config="$HOME/.nugitconfig"
    if [[ ! -f "$nu_config" && -f "$template_file" ]]; then
        log_info "Creating Nu Git config from template"
        cp "$template_file" "$nu_config"
        log_info "Created Nu Git config (edit manually): $nu_config"
    else
        log_info "Nu Git config already exists: $nu_config"
    fi
    
    log_success "Git configuration setup completed"
}

setup_github_keys() {
    log_step "Setting up GitHub SSH keys"
    
    # Only download keys on Linux, as macOS should use 1Password
    if ! is_linux; then
        log_info "Skipping GitHub SSH key download (not on Linux)"
        return 0
    fi
    
    if [[ -z "${GITHUB_USER:-}" ]]; then
        log_warning "GITHUB_USER not set, skipping SSH key setup"
        return 0
    fi
    
    local ssh_dir="$HOME/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"
    
    ensure_dir "$ssh_dir"
    
    log_info "Downloading authorized keys from GitHub user: $GITHUB_USER"
    
    # Backup existing authorized_keys
    backup_file "$auth_keys"
    
    # Download keys from GitHub
    if download_file "https://github.com/${GITHUB_USER}.keys" "$auth_keys"; then
        chmod 600 "$auth_keys"
        log_success "Downloaded authorized keys from GitHub user: $GITHUB_USER"
        
        # Validate the downloaded keys
        if [[ -s "$auth_keys" ]]; then
            local key_count
            key_count=$(wc -l < "$auth_keys")
            log_info "Downloaded $key_count SSH keys"
        else
            log_warning "No SSH keys found for user: $GITHUB_USER"
        fi
    else
        log_error "Failed to download SSH keys from GitHub"
        return 1
    fi
}

verify_git_setup() {
    log_step "Verifying Git setup"
    
    # Check Git user configuration
    local git_name git_email
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_name" ]]; then
        log_info "Git user name: $git_name"
    else
        log_warning "Git user name not configured globally"
    fi
    
    if [[ -n "$git_email" ]]; then
        log_info "Git user email: $git_email"
    else
        log_warning "Git user email not configured globally"
    fi
    
    # Check for SSH keys
    if [[ -d "$HOME/.ssh" ]]; then
        local ssh_keys
        ssh_keys=$(find "$HOME/.ssh" -name "*.pub" -type f 2>/dev/null | wc -l)
        if [[ $ssh_keys -gt 0 ]]; then
            log_info "Found $ssh_keys SSH public key(s)"
        else
            log_info "No SSH public keys found"
        fi
    fi
    
    log_success "Git setup verification completed"
}

main() {
    check_git_installation
    setup_git_config
    setup_github_keys
    verify_git_setup
    
    print_footer "Git setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi