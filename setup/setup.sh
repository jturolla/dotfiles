#!/bin/bash

###############################################################################
# Dotfiles Setup Script
# Main entry point for setting up dotfiles environment
#
# Usage:
#   ./setup.sh [options]
#   
# Options:
#   -h, --help        Show this help message
#   --skip-brew       Skip Homebrew installation and package setup
#   --debug          Enable debug logging
###############################################################################

set -euo pipefail

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            grep "^#" "$0" | head -15 | cut -c3-
            exit 0
            ;;
        --skip-brew)
            export SKIP_BREW="true"
            shift
            ;;
        --debug)
            export LOG_LEVEL="DEBUG"
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Get script directory and change to dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source configuration and utilities
source "setup/setup-config.sh"
source "lib/setup-utils.sh"

print_header "Dotfiles Setup"

check_prerequisites() {
    log_step "Checking system prerequisites"
    
    check_system_requirements
    
    # Check if we have required directories
    ensure_dir "$HOME/dev"
    ensure_dir "$HOME/.ssh"
    ensure_dir "$HOME/Desktop/Screenshots"
    ensure_dir "tmp"
    
    # Ensure .env file exists
    touch "$HOME/.env"
    
    log_success "Prerequisites check completed"
}

setup_shell() {
    log_step "Configuring shell environment"
    
    local current_shell
    current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" != "bash" ]]; then
        log_info "Current shell is $current_shell, changing to bash"
        if command_exists chsh; then
            chsh -s /bin/bash || log_warning "Failed to change shell to bash"
        else
            log_warning "chsh command not available, please manually change shell to bash"
        fi
    else
        log_info "Current shell is already bash"
    fi
}

link_dotfiles() {
    log_step "Linking dotfiles"
    
    # Run the linking script
    if [[ -f "setup/setup-link.sh" ]]; then
        source "setup/setup-link.sh"
    else
        fail_fast "setup-link.sh not found"
    fi
}

setup_platform_specific() {
    log_step "Running platform-specific setup"
    
    case "$OSTYPE" in
        darwin*)
            log_info "Running macOS setup"
            if [[ -f "setup/setup-darwin.sh" ]]; then
                source "setup/setup-darwin.sh"
            else
                fail_fast "setup-darwin.sh not found"
            fi
            ;;
        linux-gnu*)
            log_info "Running Linux setup"
            if [[ -f "setup/setup-linux.sh" ]]; then
                source "setup/setup-linux.sh"
            else
                fail_fast "setup-linux.sh not found"
            fi
            ;;
        *)
            fail_fast "Unsupported operating system: $OSTYPE"
            ;;
    esac
}

setup_applications() {
    log_step "Setting up applications"
    
    # Setup Vim
    if [[ "${SKIP_VIM:-false}" != "true" && -f "setup/setup-vim.sh" ]]; then
        log_info "Setting up Vim"
        source "setup/setup-vim.sh"
    else
        log_info "Skipping Vim setup"
    fi
    
    # Setup Git
    if [[ "${SKIP_GIT:-false}" != "true" && -f "setup/setup-git.sh" ]]; then
        log_info "Setting up Git"
        source "setup/setup-git.sh"
    else
        log_info "Skipping Git setup"
    fi
    
    # Setup Fonts
    if [[ "${SKIP_FONTS:-false}" != "true" && -f "setup/setup-fonts.sh" ]]; then
        log_info "Setting up Fonts"
        source "setup/setup-fonts.sh"
    else
        log_info "Skipping Fonts setup"
    fi
}

show_completion_message() {
    print_footer "Dotfiles setup completed successfully!"
    
    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal for all changes to take effect"
    echo "  2. Set your terminal font to a Powerline font (e.g., 'Meslo LG M for Powerline')"
    
    if is_macos; then
        echo "  3. Optionally run: make setup-1password-ssh (to enable 1Password SSH)"
    fi
    
    echo
    log_info "Available commands:"
    echo "  make help          - Show all available make targets"
    echo "  make lint          - Run shellcheck on all scripts"
    echo "  make setup-test    - Run setup with test configuration"
    echo
}

main() {
    # Load configuration first
    load_configuration
    validate_configuration
    
    # Run setup steps
    check_prerequisites
    setup_shell
    link_dotfiles
    setup_platform_specific
    setup_applications
    
    show_completion_message
}

main "$@"
