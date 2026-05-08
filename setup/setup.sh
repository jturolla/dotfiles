#!/bin/bash

###############################################################################
# Dotfiles Setup Script
# Main entry point for setting up dotfiles environment
#
# Usage:
#   ./setup.sh [options]
#
# Options:
#   -h, --help     Show this help message
#   --skip-brew    Skip Homebrew installation and package setup (macOS)
#   --debug        Enable debug logging
###############################################################################

set -euo pipefail

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            grep "^#" "$0" | head -14 | cut -c3-
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

SETUP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SETUP_SCRIPT_DIR/.." && pwd)"
cd "$DOTFILES_ROOT" || exit 1
export DOTFILES_ROOT

# shellcheck source=setup/setup-config.sh
source "$DOTFILES_ROOT/setup/setup-config.sh"

print_header "Dotfiles Setup"

check_prerequisites() {
    log_step "Checking system prerequisites"

    check_system_requirements

    ensure_dir "$HOME/dev"
    ensure_dir "$HOME/.ssh"
    ensure_dir "$HOME/Desktop/Screenshots"
    ensure_dir "$DOTFILES_ROOT/tmp"

    touch "$HOME/.env"

    log_success "Prerequisites check completed"
}

setup_shell() {
    log_step "Configuring shell environment"

    local current_shell
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" != "bash" ]]; then
        log_info "Current shell is $current_shell; setup links .zshrc and .bash_profile"
        log_info "To use bash as login shell (optional): chsh -s /bin/bash"
    else
        log_info "Current shell is already bash"
    fi

    log_success "Shell hint completed"
}

run_link_dotfiles() {
    log_step "Linking dotfiles"
    bash "$DOTFILES_ROOT/setup/setup-link.sh"
}

run_platform_setup() {
    log_step "Running platform-specific setup"

    case "$OSTYPE" in
        darwin*)
            log_info "Running macOS setup"
            bash "$DOTFILES_ROOT/setup/setup-darwin.sh"
            ;;
        linux-gnu*)
            log_info "Running Linux setup"
            bash "$DOTFILES_ROOT/setup/setup-linux.sh"
            ;;
        *)
            fail_fast "Unsupported operating system: $OSTYPE"
            ;;
    esac
}

run_application_setup() {
    log_step "Setting up applications"

    if [[ "${SKIP_VIM:-false}" != "true" ]]; then
        bash "$DOTFILES_ROOT/setup/setup-vim.sh"
    else
        log_info "Skipping Vim setup"
    fi

    if [[ "${SKIP_GIT:-false}" != "true" ]]; then
        bash "$DOTFILES_ROOT/setup/setup-git.sh"
    else
        log_info "Skipping Git setup"
    fi

    if [[ "${SKIP_FONTS:-false}" != "true" ]]; then
        bash "$DOTFILES_ROOT/setup/setup-fonts.sh"
    else
        log_info "Skipping Fonts setup"
    fi

    log_success "Application setup steps finished"
}

show_completion_message() {
    print_footer "Dotfiles setup completed successfully!"

    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal for all changes to take effect"
    echo "  2. Set your terminal font to a Powerline font (e.g., Meslo LG M for Powerline)"

    if is_macos; then
        echo "  3. Optionally run: make setup-1password-ssh"
    fi

    echo
    log_info "Useful commands: make help, make lint, ./setup/setup-link.sh (link only)"
    echo
}

main() {
    load_configuration
    validate_configuration

    check_prerequisites
    setup_shell
    run_link_dotfiles
    run_platform_setup
    run_application_setup

    show_completion_message
}

main "$@"
