#!/bin/bash

###############################################################################
# Setup Configuration Loader
# Loads and validates configuration from .setupconf
###############################################################################

set -euo pipefail

# Get the script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_ROOT/lib/setup-utils.sh"

print_header "Loading Setup Configuration"

load_configuration() {
    # Use custom config file if specified (for testing), otherwise use default
    local config_file="$DOTFILES_ROOT/${SETUPCONF_FILE:-.setupconf}"
    
    if [[ -f "$config_file" ]]; then
        log_info "Loading configuration from $(basename "$config_file")"
        # shellcheck source=/dev/null
        source "$config_file"
    else
        log_warning "No $(basename "$config_file") found"
        if [[ "$config_file" == *".setupconf.test" ]]; then
            log_info "Test configuration file not found - this is normal for test mode"
        else
            log_info "Please copy setup/.setupconf.template to .setupconf and customize it"
        fi
        log_info "Using default values for now..."
    fi
    
    # Set default values for configuration variables
    export GITHUB_USER="${GITHUB_USER:-jturolla}"
    export GIT_NAME="${GIT_NAME:-$(git config --global user.name 2>/dev/null || echo "Your Name")}"
    export GIT_EMAIL="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || echo "your.email@example.com")}"
    export EXTRA_PACKAGES="${EXTRA_PACKAGES:-}"
    export VIM_COLORSCHEME="${VIM_COLORSCHEME:-monokai}"
    export SSH_PORT="${SSH_PORT:-22}"
    export SKIP_BREW="${SKIP_BREW:-false}"
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    
    log_info "Configuration loaded:"
    log_info "  GITHUB_USER: $GITHUB_USER"
    log_info "  GIT_NAME: $GIT_NAME"
    log_info "  GIT_EMAIL: $GIT_EMAIL"
    log_info "  SKIP_BREW: $SKIP_BREW"
    log_info "  LOG_LEVEL: $LOG_LEVEL"
    
    if [[ -n "$EXTRA_PACKAGES" ]]; then
        log_info "  EXTRA_PACKAGES: $EXTRA_PACKAGES"
    fi
    
    # Show which config file was used
    if [[ "$config_file" != "$DOTFILES_ROOT/.setupconf" ]]; then
        log_info "  CONFIG_FILE: $(basename "$config_file")"
    fi
}

validate_configuration() {
    log_step "Validating configuration"
    
    # Check for required variables
    local required_vars=()
    
    # Only require GITHUB_USER on Linux systems for SSH key setup
    if is_linux; then
        required_vars+=("GITHUB_USER")
    fi
    
    # Validate email format
    if [[ ! "$GIT_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_warning "GIT_EMAIL format appears invalid: $GIT_EMAIL"
    fi
    
    # Validate SSH port
    if [[ ! "$SSH_PORT" =~ ^[0-9]+$ ]] || [[ "$SSH_PORT" -lt 1 ]] || [[ "$SSH_PORT" -gt 65535 ]]; then
        fail_fast "SSH_PORT must be a valid port number (1-65535): $SSH_PORT"
    fi
    
    # Validate boolean values
    if [[ "$SKIP_BREW" != "true" && "$SKIP_BREW" != "false" ]]; then
        fail_fast "SKIP_BREW must be 'true' or 'false': $SKIP_BREW"
    fi
    
    log_success "Configuration validation passed"
}

create_default_config() {
    local template_file="$SCRIPT_DIR/.setupconf.template"
    local config_file="$DOTFILES_ROOT/.setupconf"
    
    # Only create default config if we're using the standard .setupconf file
    if [[ "${SETUPCONF_FILE:-.setupconf}" == ".setupconf" ]]; then
        if [[ ! -f "$config_file" && -f "$template_file" ]]; then
            log_step "Creating default .setupconf from template"
            cp "$template_file" "$config_file"
            log_success "Created .setupconf from template"
            log_info "Please edit .setupconf to customize your setup"
        fi
    fi
}

main() {
    create_default_config
    load_configuration
    validate_configuration
    
    # Export DOTFILES_ROOT for other scripts
    export DOTFILES_ROOT
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi