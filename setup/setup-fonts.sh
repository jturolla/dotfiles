#!/bin/bash

###############################################################################
# Fonts Setup Script
# Downloads and installs Powerline fonts
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Fonts Setup"

check_font_requirements() {
    log_step "Checking font installation requirements"
    
    # Check if git is available for cloning
    if ! command_exists git; then
        fail_fast "Git is required for font installation but not found"
    fi
    
    log_success "Font installation requirements met"
}

setup_fonts() {
    log_step "Setting up Powerline fonts"
    
    # Ensure we have the DOTFILES_ROOT variable
    if [[ -z "${DOTFILES_ROOT:-}" ]]; then
        DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi
    
    # Create temporary directory for fonts
    local tmp_fonts_dir="$DOTFILES_ROOT/tmp/powerline-fonts"
    ensure_dir "$(dirname "$tmp_fonts_dir")"
    
    # Clean up any existing fonts directory
    if [[ -d "$tmp_fonts_dir" ]]; then
        log_info "Cleaning up existing fonts directory"
        rm -rf "$tmp_fonts_dir"
    fi
    
    ensure_dir "$tmp_fonts_dir"
    
    # Clone powerline fonts repository
    log_info "Downloading powerline fonts repository"
    if git clone https://github.com/powerline/fonts.git --depth=1 "$tmp_fonts_dir"; then
        log_success "Powerline fonts repository downloaded"
    else
        fail_fast "Failed to download powerline fonts repository"
    fi
    
    # Verify the installation script exists
    local install_script="$tmp_fonts_dir/install.sh"
    if [[ ! -f "$install_script" ]]; then
        fail_fast "Font installation script not found: $install_script"
    fi
    
    # Make install script executable
    chmod +x "$install_script"
    
    # Install fonts
    log_info "Installing powerline fonts (this may take a moment)"
    if (cd "$tmp_fonts_dir" && ./install.sh); then
        log_success "Powerline fonts installed successfully"
    else
        log_warning "Font installation may have failed or been incomplete"
    fi
}

cleanup_fonts() {
    log_step "Cleaning up font installation files"
    
    local tmp_fonts_dir="$DOTFILES_ROOT/tmp/powerline-fonts"
    
    if [[ -d "$tmp_fonts_dir" ]]; then
        rm -rf "$tmp_fonts_dir"
        log_success "Font installation files cleaned up"
    else
        log_info "No font installation files to clean up"
    fi
}

verify_font_installation() {
    log_step "Verifying font installation"
    
    if is_macos; then
        local font_dir="$HOME/Library/Fonts"
        if [[ -d "$font_dir" ]]; then
            local powerline_fonts
            powerline_fonts=$(find "$font_dir" -name "*Powerline*" -o -name "*for Powerline*" 2>/dev/null | wc -l)
            if [[ $powerline_fonts -gt 0 ]]; then
                log_info "Found $powerline_fonts Powerline font(s) in $font_dir"
            else
                log_warning "No Powerline fonts found in $font_dir"
            fi
        fi
    elif is_linux; then
        local font_dirs=("$HOME/.local/share/fonts" "$HOME/.fonts")
        local total_fonts=0
        
        for font_dir in "${font_dirs[@]}"; do
            if [[ -d "$font_dir" ]]; then
                local powerline_fonts
                powerline_fonts=$(find "$font_dir" -name "*Powerline*" -o -name "*for Powerline*" 2>/dev/null | wc -l)
                total_fonts=$((total_fonts + powerline_fonts))
                if [[ $powerline_fonts -gt 0 ]]; then
                    log_info "Found $powerline_fonts Powerline font(s) in $font_dir"
                fi
            fi
        done
        
        if [[ $total_fonts -eq 0 ]]; then
            log_warning "No Powerline fonts found in user font directories"
        fi
    fi
    
    log_success "Font installation verification completed"
}

show_font_instructions() {
    log_info "Font installation completed!"
    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal application"
    echo "  2. Go to your terminal's font settings"
    echo "  3. Select a Powerline font (recommended: 'Meslo LG M for Powerline')"
    echo "  4. Set the font size to your preference (12-14pt recommended)"
    echo
    
    if is_macos; then
        log_info "For iTerm2:"
        echo "  - Preferences > Profiles > Text > Font"
        echo "  - Choose 'Meslo LG M for Powerline' or another Powerline font"
    fi
    
    echo
    log_info "If you don't see Powerline fonts in your terminal:"
    echo "  - Try restarting your terminal completely"
    echo "  - Check if the fonts are installed in the correct directory"
    echo "  - Some terminals may require a system restart"
}

main() {
    check_font_requirements
    setup_fonts
    cleanup_fonts
    verify_font_installation
    show_font_instructions
    
    print_footer "Fonts setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi