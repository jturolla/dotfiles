#!/bin/bash

###############################################################################
# macOS Setup Script
# Sets up macOS-specific environment and applications
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "macOS Environment Setup"

check_macos_requirements() {
    log_step "Checking macOS requirements"
    
    if ! is_macos; then
        fail_fast "This script is only for macOS systems"
    fi
    
    log_success "macOS system confirmed"
}

setup_xcode_tools() {
    log_step "Setting up Xcode Command Line Tools"
    
    if xcode-select -p >/dev/null 2>&1; then
        log_info "Xcode Command Line Tools are already installed"
        return 0
    fi
    
    log_info "Installing Xcode Command Line Tools"
    xcode-select --install || {
        log_warning "Xcode tools installation may have failed or was cancelled"
        log_info "Please install manually if needed: xcode-select --install"
    }
    
    # Wait for installation to complete
    log_info "Waiting for Xcode tools installation to complete..."
    while ! xcode-select -p >/dev/null 2>&1; do
        sleep 5
        log_debug "Still waiting for Xcode tools..."
    done
    
    log_success "Xcode Command Line Tools installed"
}

setup_rosetta() {
    log_step "Setting up Rosetta 2"
    
    # Check if we're on Apple Silicon
    if [[ $(uname -m) != "arm64" ]]; then
        log_info "Not on Apple Silicon, skipping Rosetta 2 setup"
        return 0
    fi
    
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        log_info "Rosetta 2 is already installed"
        return 0
    fi
    
    log_info "Installing Rosetta 2"
    softwareupdate --install-rosetta --agree-to-license || {
        log_warning "Failed to install Rosetta 2 automatically"
        log_info "You may need to install it manually later"
    }
    
    log_success "Rosetta 2 setup completed"
}

setup_homebrew() {
    log_step "Setting up Homebrew"
    
    if [[ "${SKIP_BREW:-false}" == "true" ]]; then
        log_info "Skipping Homebrew setup as requested"
        return 0
    fi
    
    if command_exists brew; then
        log_info "Homebrew is already installed"
        log_step "Updating Homebrew"
        brew update || log_warning "Failed to update Homebrew"
    else
        log_info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            fail_fast "Failed to install Homebrew"
        }
        
        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Verify Homebrew is working
    if ! command_exists brew; then
        fail_fast "Homebrew installation failed or is not in PATH"
    fi
    
    log_step "Running Homebrew doctor"
    brew doctor || log_warning "Homebrew doctor found some issues (this is often normal)"
    
    # Install packages from Brewfile if it exists
    local brewfile="$DOTFILES_ROOT/Brewfile"
    if [[ -f "$brewfile" ]]; then
        log_step "Installing packages from Brewfile"
        cd "$DOTFILES_ROOT"
        brew bundle --file="$brewfile" || log_warning "Some Brewfile packages may have failed to install"
    else
        log_warning "No Brewfile found, skipping package installation"
    fi
    
    log_step "Upgrading existing packages"
    brew upgrade || log_warning "Some packages may have failed to upgrade"
    
    log_success "Homebrew setup completed"
}

configure_macos_settings() {
    log_step "Configuring macOS system settings"
    
    # Clear dock persistent apps
    log_info "Clearing dock persistent apps"
    defaults write com.apple.dock persistent-apps -array
    
    # Disable press-and-hold for keys in favor of key repeat
    log_info "Configuring keyboard repeat settings"
    defaults write -g ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    
    # Decrease delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 12
    
    # Set mouse scaling (speed)
    log_info "Configuring mouse settings"
    defaults write -g com.apple.mouse.scaling -float 10.0
    
    # Show hidden files in Finder
    log_info "Configuring Finder settings"
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Restart affected applications
    log_info "Restarting affected applications"
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    
    log_success "macOS settings configured"
    log_info "Some changes will take effect after restart"
}

install_extra_packages() {
    if [[ -n "${EXTRA_PACKAGES:-}" && "${SKIP_BREW:-false}" != "true" ]]; then
        log_step "Installing extra packages: $EXTRA_PACKAGES"
        
        for package in $EXTRA_PACKAGES; do
            log_info "Installing $package"
            brew install "$package" || log_warning "Failed to install $package"
        done
        
        log_success "Extra packages installation completed"
    fi
}

main() {
    check_macos_requirements
    setup_xcode_tools
    setup_rosetta
    setup_homebrew
    install_extra_packages
    configure_macos_settings
    
    print_footer "macOS setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi