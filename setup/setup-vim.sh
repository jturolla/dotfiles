#!/bin/bash

###############################################################################
# Vim Setup Script
# Installs and configures Vim with plugins
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Vim Configuration Setup"

check_vim_installation() {
    log_step "Checking Vim installation"
    
    if ! command_exists vim; then
        if is_macos && command_exists brew; then
            log_info "Installing Vim via Homebrew"
            brew install vim || fail_fast "Failed to install Vim"
        elif is_linux; then
            log_info "Installing Vim via package manager"
            install_package vim "Vim text editor"
        else
            fail_fast "Vim is not installed and cannot be installed automatically"
        fi
    else
        local vim_version
        vim_version=$(vim --version | head -1 | cut -d' ' -f5)
        log_info "Vim is already installed (version: $vim_version)"
    fi
}

setup_vim_plug() {
    log_step "Setting up vim-plug plugin manager"
    
    local plug_dir="$HOME/.vim/autoload"
    local plug_file="$plug_dir/plug.vim"
    
    ensure_dir "$plug_dir"
    
    if [[ -f "$plug_file" ]]; then
        log_info "vim-plug is already installed"
        return 0
    fi
    
    log_info "Installing vim-plug"
    download_file "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" "$plug_file"
    
    if [[ -f "$plug_file" ]]; then
        log_success "vim-plug installed successfully"
    else
        fail_fast "Failed to install vim-plug"
    fi
}

install_vim_plugins() {
    log_step "Installing Vim plugins"
    
    # Check if .vimrc exists and has plugins
    local vimrc="$HOME/.vimrc"
    if [[ ! -f "$vimrc" ]]; then
        log_warning ".vimrc not found, skipping plugin installation"
        return 0
    fi
    
    if ! grep -q "call plug#" "$vimrc"; then
        log_info "No vim-plug configuration found in .vimrc"
        return 0
    fi
    
    log_info "Installing/updating Vim plugins (this may take a moment)"
    
    # Install plugins in non-interactive mode
    vim +PlugInstall +qall < /dev/null || {
        log_warning "Plugin installation may have failed or been incomplete"
        log_info "You can run ':PlugInstall' manually in Vim later"
    }
    
    log_success "Vim plugins installation completed"
}

configure_vim_colorscheme() {
    log_step "Configuring Vim colorscheme"
    
    local colorscheme="${VIM_COLORSCHEME:-monokai}"
    local vimrc="$HOME/.vimrc"
    
    if [[ ! -f "$vimrc" ]]; then
        log_warning ".vimrc not found, cannot configure colorscheme"
        return 0
    fi
    
    # Check if colorscheme is already set
    if grep -q "colorscheme.*$colorscheme" "$vimrc"; then
        log_info "Colorscheme '$colorscheme' is already configured"
        return 0
    fi
    
    log_info "Configuring colorscheme: $colorscheme"
    
    # Note: This is informational since colorscheme should be in .vimrc template
    log_info "Colorscheme should be configured in your .vimrc file"
    log_info "Add this line to your .vimrc: colorscheme $colorscheme"
}

verify_vim_setup() {
    log_step "Verifying Vim setup"
    
    # Check Vim configuration
    local vimrc="$HOME/.vimrc"
    if [[ -L "$vimrc" ]]; then
        local target
        target=$(readlink "$vimrc")
        log_info "Vim config linked: $vimrc -> $target"
    elif [[ -f "$vimrc" ]]; then
        log_info "Vim config exists: $vimrc"
    else
        log_warning "Vim config not found: $vimrc"
    fi
    
    # Check vim-plug
    local plug_file="$HOME/.vim/autoload/plug.vim"
    if [[ -f "$plug_file" ]]; then
        log_info "vim-plug is installed"
    else
        log_warning "vim-plug is not installed"
    fi
    
    # Check for plugins directory
    local plugin_dir="$HOME/.vim/plugged"
    if [[ -d "$plugin_dir" ]]; then
        local plugin_count
        plugin_count=$(find "$plugin_dir" -maxdepth 1 -type d | wc -l)
        plugin_count=$((plugin_count - 1))  # Subtract 1 for the parent directory
        log_info "Found $plugin_count installed plugin(s)"
    else
        log_info "No plugins directory found (normal if no plugins are configured)"
    fi
    
    log_success "Vim setup verification completed"
}

main() {
    check_vim_installation
    setup_vim_plug
    install_vim_plugins
    configure_vim_colorscheme
    verify_vim_setup
    
    print_footer "Vim setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi