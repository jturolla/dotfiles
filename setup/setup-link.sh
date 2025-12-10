#!/bin/bash

###############################################################################
# Dotfiles Linking Script
# Creates symbolic links for dotfiles
###############################################################################

set -euo pipefail

# Source utilities if not already loaded
if ! command -v log_info >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    source "$DOTFILES_ROOT/lib/setup-utils.sh"
    source "$DOTFILES_ROOT/setup/setup-config.sh"
fi

print_header "Linking Dotfiles"

link_dotfiles() {
    log_step "Creating symbolic links for dotfiles"

    # Ensure we have the DOTFILES_ROOT variable
    if [[ -z "${DOTFILES_ROOT:-}" ]]; then
        DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi

    log_info "Linking dotfiles from: $DOTFILES_ROOT"

    # Define files to link
    local files_to_link=(
        "tmux.conf:.tmux.conf"
        "vimrc:.vimrc"
        "vimrc:.config/nvim/init.vim"
        "gitconfig:.gitconfig"
        "gitignore:.gitignore"
        "bash_profile:.bash_profile"
        "zshrc:.zshrc"
        "ssh_config:.ssh/config"
    )

    # Create .ssh directory if it doesn't exist
    ensure_dir "$HOME/.ssh"

    # Link each file
    for file_mapping in "${files_to_link[@]}"; do
        local source_file="${file_mapping%:*}"
        local target_file="${file_mapping#*:}"

        local source_path="$DOTFILES_ROOT/$source_file"
        local target_path="$HOME/$target_file"

        if [[ ! -f "$source_path" ]]; then
            log_warning "Source file not found: $source_path"
            continue
        fi

        # Create target directory if needed
        local target_dir
        target_dir="$(dirname "$target_path")"
        ensure_dir "$target_dir"

        # Create the symbolic link
        safe_symlink "$source_path" "$target_path"
    done

    log_success "Dotfiles linking completed"
}

validate_links() {
    log_step "Validating symbolic links"

    local broken_links=()

    # Check each expected link
    local expected_links=(
        "$HOME/.tmux.conf"
        "$HOME/.vimrc"
        "$HOME/.gitconfig"
        "$HOME/.gitignore"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.ssh/config"
        "$HOME/.config/nvim/init.vim"
    )

    for link in "${expected_links[@]}"; do
        if [[ -L "$link" ]]; then
            if [[ ! -e "$link" ]]; then
                broken_links+=("$link")
                log_warning "Broken symbolic link: $link"
            else
                log_debug "Valid link: $link -> $(readlink "$link")"
            fi
        elif [[ -f "$link" ]]; then
            log_info "File exists (not a symlink): $link"
        else
            log_warning "Missing file/link: $link"
        fi
    done

    if [[ ${#broken_links[@]} -eq 0 ]]; then
        log_success "All symbolic links are valid"
    else
        log_error "Found ${#broken_links[@]} broken symbolic links"
        return 1
    fi
}

main() {
    link_dotfiles
    validate_links

    print_footer "Dotfiles linking completed!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
