#!/bin/bash

###############################################################################
# 1Password SSH Agent Setup
# Configures SSH to use 1Password as the SSH agent
# 
# Run this AFTER the main setup is complete and 1Password is installed
###############################################################################

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/setup-utils.sh"

print_header "1Password SSH Agent Setup"

check_prerequisites() {
    log_step "Checking prerequisites"
    
    if ! is_macos; then
        log_warning "1Password SSH agent is primarily designed for macOS"
        log_info "This script may not work correctly on other systems"
    fi
    
    # Check if 1Password is installed
    local onepassword_installed=false
    
    if command_exists op; then
        log_info "1Password CLI found"
        onepassword_installed=true
    elif [[ -d "/Applications/1Password 7 - Password Manager.app" ]]; then
        log_info "1Password 7 application found"
        onepassword_installed=true
    elif [[ -d "/Applications/1Password.app" ]]; then
        log_info "1Password 8 application found"  
        onepassword_installed=true
    fi
    
    if [[ "$onepassword_installed" != "true" ]]; then
        log_warning "1Password does not appear to be installed"
        log_info "This script configures SSH to use 1Password's SSH agent"
        log_info "Please install 1Password first:"
        log_info "  - Download from: https://1password.com/downloads/"
        log_info "  - Or install via Homebrew: brew install --cask 1password"
        echo
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled. Install 1Password and run this script again."
            exit 0
        fi
        log_warning "Continuing without 1Password verification..."
    fi
    
    log_success "Prerequisites check completed"
}

setup_ssh_config() {
    log_step "Configuring SSH to use 1Password agent"
    
    local ssh_config="$HOME/.ssh/config"
    ensure_dir "$(dirname "$ssh_config")"
    
    # Backup existing SSH config
    backup_file "$ssh_config"
    
    # Check if 1Password SSH configuration already exists
    if [[ -f "$ssh_config" ]] && grep -q "IdentityAgent.*1password" "$ssh_config"; then
        log_info "1Password SSH configuration already exists in SSH config"
        return 0
    fi
    
    # Add 1Password SSH agent configuration
    local onepassword_config="
# 1Password SSH Agent Configuration
Host *
    IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"
    AddKeysToAgent yes
    UseKeychain yes
"
    
    if [[ -f "$ssh_config" ]]; then
        # Prepend to existing config
        local temp_file
        temp_file=$(mktemp)
        echo "$onepassword_config" > "$temp_file"
        echo "" >> "$temp_file"
        cat "$ssh_config" >> "$temp_file"
        mv "$temp_file" "$ssh_config"
    else
        # Create new config
        echo "$onepassword_config" > "$ssh_config"
    fi
    
    chmod 600 "$ssh_config"
    log_success "SSH configuration updated for 1Password agent"
}

verify_setup() {
    log_step "Verifying 1Password SSH setup"
    
    local sock_path="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    
    if [[ -S "$sock_path" ]]; then
        log_success "1Password SSH agent socket found"
    else
        log_warning "1Password SSH agent socket not found at: $sock_path"
        log_info "This is normal if 1Password is not running or SSH agent is not enabled"
    fi
    
    # Test SSH agent
    if SSH_AUTH_SOCK="$sock_path" ssh-add -l >/dev/null 2>&1; then
        log_success "1Password SSH agent is responding"
    else
        log_info "1Password SSH agent is not responding"
        log_info "This is normal if you haven't added any SSH keys to 1Password yet"
    fi
}

show_next_steps() {
    log_info "Next steps to complete 1Password SSH setup:"
    echo
    log_info "1. Open 1Password app"
    log_info "2. Go to Settings/Preferences > Developer"  
    log_info "3. Enable 'Use the SSH agent'"
    log_info "4. Add your SSH keys to 1Password (import existing or generate new)"
    log_info "5. Test with: ssh -T git@github.com"
    echo
    log_info "For more details, see: https://developer.1password.com/docs/ssh/"
}

main() {
    check_prerequisites
    setup_ssh_config
    verify_setup
    show_next_steps
    
    print_footer "1Password SSH setup completed!"
    log_info "You may need to restart your terminal for changes to take effect"
}

main "$@" 