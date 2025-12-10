#!/bin/bash

###############################################################################
# Vim/Neovim Setup Script
# Installs and configures Vim/Neovim with plugins
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Vim/Neovim Configuration Setup"

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

setup_neovim_plug() {
    log_step "Setting up vim-plug for Neovim"
    
    local nvim_plug_file="$HOME/.config/nvim/autoload/plug.vim"
    
    if [[ -f "$nvim_plug_file" ]]; then
        log_info "vim-plug for Neovim is already installed"
        return 0
    fi
    
    if ! command_exists curl; then
        fail_fast "curl is required to install vim-plug for Neovim"
    fi
    
    log_info "Installing vim-plug for Neovim"
    # Use the exact command requested to ensure directories are created
    curl -fLo "$nvim_plug_file" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || fail_fast "Failed to install vim-plug for Neovim"
    
    if [[ -f "$nvim_plug_file" ]]; then
        log_success "vim-plug for Neovim installed successfully"
    else
        fail_fast "Failed to install vim-plug for Neovim"
    fi
}

install_vim_plugins() {
    log_step "Installing Neovim plugins"
    
    # Check if Neovim is installed
    if ! command_exists nvim; then
        log_warning "Neovim not found, skipping plugin installation"
        log_info "Install Neovim to use lazy.nvim plugin manager"
        return 0
    fi
    
    # Check if init.lua exists
    local init_lua="$HOME/.config/nvim/init.lua"
    if [[ ! -f "$init_lua" ]]; then
        log_warning "Neovim init.lua not found, skipping plugin installation"
        return 0
    fi
    
    log_info "Installing/updating Neovim plugins with lazy.nvim (this may take a moment)"
    
    # Install plugins in non-interactive mode using lazy.nvim
    nvim --headless "+Lazy! sync" +qa || {
        log_warning "Plugin installation may have failed or been incomplete"
        log_info "You can run ':Lazy sync' manually in Neovim later"
    }
    
    log_success "Neovim plugins installation completed"
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
    log_step "Verifying Vim/Neovim setup"
    
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
    
    # Check Neovim configuration
    local init_lua="$HOME/.config/nvim/init.lua"
    if [[ -L "$init_lua" ]]; then
        local target
        target=$(readlink "$init_lua")
        log_info "Neovim config linked: $init_lua -> $target"
    elif [[ -f "$init_lua" ]]; then
        log_info "Neovim config exists: $init_lua"
    else
        log_warning "Neovim config not found: $init_lua"
    fi
    
    # Check for lazy.nvim plugins directory
    local lazy_dir="$HOME/.local/share/nvim/lazy"
    if [[ -d "$lazy_dir" ]]; then
        local plugin_count
        plugin_count=$(find "$lazy_dir" -maxdepth 1 -type d | wc -l)
        plugin_count=$((plugin_count - 1))  # Subtract 1 for the parent directory
        log_info "Found $plugin_count lazy.nvim plugin(s)"
    else
        log_info "No lazy.nvim plugins directory found (will be created on first nvim launch)"
    fi
    
    log_success "Vim/Neovim setup verification completed"
}

main() {
    check_vim_installation
    setup_vim_plug
    setup_neovim_plug
    install_vim_plugins
    configure_vim_colorscheme
    verify_vim_setup
    
    print_footer "Vim/Neovim setup completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi