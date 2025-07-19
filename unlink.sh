#!/bin/bash

###############################################################################
# Dotfiles Unlink Script
# Removes symbolic links created by the setup process
#
# ⚠️  WARNING: This script should be run through the Makefile only!
#    Use: make unlink or make unlink-dry-run
#
# Usage (via Makefile):
#   make unlink          # Unlink all dotfiles
#   make unlink-dry-run  # Show what would be unlinked
###############################################################################

set -euo pipefail

# Check if running via Makefile
if [[ "${MAKE_CONTROLLED:-}" != "true" ]]; then
    echo "❌ This script should only be run through the Makefile!"
    echo ""
    echo "Available unlink commands:"
    echo "  make unlink          # Unlink all dotfiles"
    echo "  make unlink-dry-run  # Show what would be unlinked"
    echo ""
    echo "Run 'make help' to see all available commands."
    exit 1
fi

# Source utilities for consistent logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/setup-utils.sh"

# Parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            grep "^#" "$0" | head -15 | cut -c3-
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

if [[ "$DRY_RUN" == "true" ]]; then
    print_header "Dotfiles Unlink (DRY RUN)"
    log_info "🔍 DRY RUN MODE - No files will be modified"
else
    print_header "Dotfiles Unlink"
fi

# List of dotfiles symlinks to remove (same as in setup-link.sh)
FILES_TO_UNLINK=(
    "$HOME/.tmux.conf"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/.gitignore"
    "$HOME/.bash_profile"
    "$HOME/.ssh/config"
)

unlink_dotfiles() {
    log_step "Unlinking dotfiles"
    
    local unlinked_count=0
    local skipped_count=0
    
    for file in "${FILES_TO_UNLINK[@]}"; do
        if [[ -L "$file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "Would unlink: $file -> $(readlink "$file")"
            else
                local target
                target=$(readlink "$file")
                unlink "$file"
                log_success "Unlinked: $file (was -> $target)"
            fi
            ((unlinked_count++))
        elif [[ -f "$file" ]]; then
            log_warning "Skipping $file (regular file, not a symlink)"
            ((skipped_count++))
        else
            log_info "Skipping $file (does not exist)"
            ((skipped_count++))
        fi
    done
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run completed. Would unlink $unlinked_count files, skip $skipped_count files"
    else
        log_success "Unlink completed. Removed $unlinked_count symlinks, skipped $skipped_count files"
    fi
}

main() {
    unlink_dotfiles
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_footer "Dotfiles unlink dry run completed!"
        echo
        log_info "This was a dry run - no files were modified."
        log_info "To actually unlink dotfiles, use: make unlink"
    else
        print_footer "Dotfiles unlink completed!"
        
        echo
        log_info "To restore dotfiles, run: make setup"
    fi
}

main "$@"
