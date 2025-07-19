#!/bin/bash

###############################################################################
# Dotfiles Setup Script
# Main entry point for setting up dotfiles environment
#
# ⚠️  WARNING: This script should be run through the Makefile only!
#    Use: make setup, make setup-test, or make setup-dry-run
#
# Usage (via Makefile):
#   make setup           # Run complete setup
#   make setup-test      # Run with test configuration
#   make setup-dry-run   # Show what would be done
#   make setup-darwin    # macOS-specific setup only
#   make setup-linux     # Linux-specific setup only
###############################################################################

set -euo pipefail

# Check if running via Makefile
if [[ "${MAKE_CONTROLLED:-}" != "true" ]]; then
    echo "❌ This script should only be run through the Makefile!"
    echo ""
    echo "Available setup commands:"
    echo "  make setup           # Run complete dotfiles setup"
    echo "  make setup-test      # Run setup with test configuration"
    echo "  make setup-dry-run   # Show what setup would do"
    echo "  make setup-darwin    # Run macOS-specific setup only"
    echo "  make setup-linux     # Run Linux-specific setup only"
    echo ""
    echo "Run 'make help' to see all available commands."
    exit 1
fi

# Check for dry-run mode
DRY_RUN="${DRY_RUN:-false}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            grep "^#" "$0" | head -20 | cut -c3-
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
# Use custom config file if specified (for testing)
SETUPCONF_FILE="${SETUPCONF_FILE:-.setupconf}"
export SETUPCONF_FILE

source "setup/setup-config.sh"
source "lib/setup-utils.sh"

if [[ "$DRY_RUN" == "true" ]]; then
    print_header "Dotfiles Setup (DRY RUN)"
    log_info "🔍 DRY RUN MODE - No changes will be made"
else
    print_header "Dotfiles Setup"
fi

check_prerequisites() {
    log_step "Checking system prerequisites"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would check system requirements"
        log_info "Would ensure directories exist: $HOME/dev, $HOME/.ssh, $HOME/Desktop/Screenshots, tmp"
        log_info "Would ensure .env file exists"
    else
        check_system_requirements
        
        # Check if we have required directories
        ensure_dir "$HOME/dev"
        ensure_dir "$HOME/.ssh"
        ensure_dir "$HOME/Desktop/Screenshots"
        ensure_dir "tmp"
        
        # Ensure .env file exists
        touch "$HOME/.env"
    fi
    
    log_success "Prerequisites check completed"
}

setup_shell() {
    log_step "Configuring shell environment"
    
    local current_shell
    current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" != "bash" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would change shell from $current_shell to bash"
        else
            log_info "Current shell is $current_shell, changing to bash"
            if command_exists chsh; then
                chsh -s /bin/bash || log_warning "Failed to change shell to bash"
            else
                log_warning "chsh command not available, please manually change shell to bash"
            fi
        fi
    else
        log_info "Current shell is already bash"
    fi
}

link_dotfiles() {
    log_step "Linking dotfiles"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would run dotfiles linking process"
        # Show what would be linked
        local files_to_link=(
            "tmux.conf:.tmux.conf"
            "vimrc:.vimrc"
            "gitconfig:.gitconfig"
            "gitignore:.gitignore"
            "bash_profile:.bash_profile"
            "ssh_config:.ssh/config"
        )
        
        for file_mapping in "${files_to_link[@]}"; do
            local source_file="${file_mapping%:*}"
            local target_file="${file_mapping#*:}"
            log_info "Would link: $source_file -> $HOME/$target_file"
        done
    else
        # Run the linking script
        if [[ -f "setup/setup-link.sh" ]]; then
            source "setup/setup-link.sh"
        else
            fail_fast "setup-link.sh not found"
        fi
    fi
}

setup_platform_specific() {
    log_step "Running platform-specific setup"
    
    case "$OSTYPE" in
        darwin*)
            log_info "Running macOS setup"
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "Would run macOS-specific setup (Homebrew, packages, etc.)"
            else
                if [[ -f "setup/setup-darwin.sh" ]]; then
                    export DRY_RUN
                    source "setup/setup-darwin.sh"
                else
                    fail_fast "setup-darwin.sh not found"
                fi
            fi
            ;;
        linux-gnu*)
            log_info "Running Linux setup"
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "Would run Linux-specific setup (packages, Docker, etc.)"
            else
                if [[ -f "setup/setup-linux.sh" ]]; then
                    export DRY_RUN
                    source "setup/setup-linux.sh"
                else
                    fail_fast "setup-linux.sh not found"
                fi
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
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would set up Vim (vim-plug, plugins, configuration)"
        else
            log_info "Setting up Vim"
            export DRY_RUN
            source "setup/setup-vim.sh"
        fi
    else
        log_info "Skipping Vim setup"
    fi
    
    # Setup Git
    if [[ "${SKIP_GIT:-false}" != "true" && -f "setup/setup-git.sh" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would set up Git (configuration, SSH keys, etc.)"
        else
            log_info "Setting up Git"
            export DRY_RUN
            source "setup/setup-git.sh"
        fi
    else
        log_info "Skipping Git setup"
    fi
    
    # Setup Fonts
    if [[ "${SKIP_FONTS:-false}" != "true" && -f "setup/setup-fonts.sh" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would set up Powerline fonts"
        else
            log_info "Setting up Fonts"
            export DRY_RUN
            source "setup/setup-fonts.sh"
        fi
    else
        log_info "Skipping Fonts setup"
    fi
}

show_completion_message() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_footer "Dotfiles setup dry run completed!"
        echo
        log_info "This was a dry run - no changes were made."
        log_info "To actually run the setup, use: make setup"
    else
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
    fi
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