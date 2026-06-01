#!/bin/bash

###############################################################################
# Change Login Shell to Bash
# Sets the user's login shell to bash via chsh (idempotent).
#
# Usage:
#   ./change-shell-to-bash.sh
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/setup-utils.sh
source "$DOTFILES_ROOT/lib/setup-utils.sh"

resolve_bash_path() {
    local candidate

    if [[ -n "${BASH_SHELL:-}" && -x "${BASH_SHELL}" ]]; then
        echo "${BASH_SHELL}"
        return 0
    fi

    for candidate in "$(command -v bash 2>/dev/null || true)" /opt/homebrew/bin/bash /usr/local/bin/bash /bin/bash; do
        if [[ -n "$candidate" && -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    fail_fast "Could not find a bash executable"
}

get_login_shell() {
    if is_macos; then
        dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}'
    else
        getent passwd "$USER" | cut -d: -f7
    fi
}

ensure_shell_in_etc_shells() {
    local shell_path="$1"

    if [[ ! -f /etc/shells ]]; then
        fail_fast "/etc/shells not found; cannot verify allowed login shells"
    fi

    if grep -Fxq "$shell_path" /etc/shells; then
        log_debug "Shell already listed in /etc/shells: $shell_path"
        return 0
    fi

    log_step "Adding $shell_path to /etc/shells (required for chsh)"
    if is_sudo; then
        echo "$shell_path" >> /etc/shells
    elif command_exists sudo; then
        echo "$shell_path" | sudo tee -a /etc/shells >/dev/null \
            || fail_fast "Failed to add $shell_path to /etc/shells"
    else
        fail_fast "sudo is required to add $shell_path to /etc/shells"
    fi
}

change_shell_to_bash() {
    local bash_path login_shell

    bash_path="$(resolve_bash_path)"
    login_shell="$(get_login_shell)"

    log_step "Setting login shell to bash"
    log_info "Target shell: $bash_path"
    log_info "Current login shell: ${login_shell:-unknown}"

    if [[ "$login_shell" == "$bash_path" ]]; then
        log_success "Login shell is already bash ($bash_path)"
        return 0
    fi

    if ! command_exists chsh; then
        fail_fast "chsh not found; cannot change login shell"
    fi

    ensure_shell_in_etc_shells "$bash_path"

    log_info "Running chsh (you may be prompted for your password)"
    chsh -s "$bash_path"
    log_success "Login shell changed to $bash_path"
    log_info "Open a new terminal session for the change to take effect"
}

print_header "Change Login Shell to Bash"
change_shell_to_bash
