#!/bin/bash

###############################################################################
# Enable Touch ID for sudo
#
# Uses pam_tid.so with the "sufficient" PAM flag: Touch ID is tried first,
# and when it is unavailable or fails, sudo falls back to password auth.
#
# On macOS Sonoma (14+) and later, configuration is written to
# /etc/pam.d/sudo_local (included by sudo and survives system updates).
# On older macOS, /etc/pam.d/sudo is edited directly.
#
# Usage:
#   sudo -s
#   make enable-sudo-touchid         # must run from a root shell
#   ./enable-sudo-touchid.sh --yes   # skip confirmation
#   ./enable-sudo-touchid.sh --disable
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/setup-utils.sh
source "$DOTFILES_ROOT/lib/setup-utils.sh"

readonly PAM_TID_LINE='auth       sufficient     pam_tid.so'
readonly PAM_TID_MODULE='pam_tid.so'
readonly SUDO_PAM='/etc/pam.d/sudo'
readonly SUDO_LOCAL='/etc/pam.d/sudo_local'
readonly SUDO_LOCAL_TEMPLATE='/etc/pam.d/sudo_local.template'
readonly PAM_DIR='/usr/lib/pam'

SKIP_CONFIRM="${SKIP_CONFIRM:-0}"
ROLLBACK_FILE=""
ROLLBACK_TARGET=""

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
        rollback_on_failure
    fi
}

trap cleanup EXIT

print_header "Enable Touch ID for sudo"

rollback_on_failure() {
    if [[ -n "$ROLLBACK_FILE" && -n "$ROLLBACK_TARGET" && -f "$ROLLBACK_FILE" ]]; then
        log_warning "Restoring backup: $ROLLBACK_FILE -> $ROLLBACK_TARGET"
        cp "$ROLLBACK_FILE" "$ROLLBACK_TARGET" || \
            log_error "Manual recovery needed — restore $ROLLBACK_FILE to $ROLLBACK_TARGET"
    elif [[ -n "$ROLLBACK_TARGET" && "$ROLLBACK_TARGET" == "$SUDO_LOCAL" && -f "$SUDO_LOCAL" ]]; then
        log_warning "Removing newly created $SUDO_LOCAL"
        rm -f "$SUDO_LOCAL" || \
            log_error "Manual recovery: rm $SUDO_LOCAL"
    fi
}

set_rollback_point() {
    local target="$1"
    ROLLBACK_TARGET="$target"
    if [[ -f "$target" ]]; then
        ROLLBACK_FILE="${target}.backup.$(date +%Y%m%d-%H%M%S)"
        cp "$target" "$ROLLBACK_FILE"
        log_info "Backup saved: $ROLLBACK_FILE"
    else
        ROLLBACK_FILE=""
    fi
}

pam_tid_module_exists() {
    [[ -f "$PAM_DIR/pam_tid.so" || -f "$PAM_DIR/pam_tid.so.2" ]]
}

password_fallback_present() {
    grep -qE '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_opendirectory\.so' "$SUDO_PAM"
}

sudo_local_include_present() {
    grep -qE '^[[:space:]]*auth[[:space:]]+include[[:space:]]+sudo_local' "$SUDO_PAM"
}

pam_tid_enabled_in() {
    local file="$1"
    [[ -f "$file" ]] && grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$file"
}

pam_tid_required_in() {
    local file="$1"
    [[ -f "$file" ]] && grep -qE '^[[:space:]]*auth[[:space:]]+(required|requisite)[[:space:]]+pam_tid\.so' "$file"
}

uses_sudo_local() {
    [[ -f "$SUDO_LOCAL_TEMPLATE" ]] && sudo_local_include_present
}

touchid_already_enabled() {
    if uses_sudo_local; then
        pam_tid_enabled_in "$SUDO_LOCAL" || pam_tid_enabled_in "$SUDO_PAM"
    else
        pam_tid_enabled_in "$SUDO_PAM"
    fi
}

validate_pam_file() {
    local file="$1"
    local label="$2"

    if pam_tid_required_in "$file"; then
        fail_fast "$label contains 'required/requisite pam_tid.so' — this can lock you out; use 'sufficient' only"
    fi

    if grep -qE '^[[:space:]]*auth[[:space:]]+.*pam_tid\.so' "$file" && \
       ! grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$file"; then
        fail_fast "$label has an unsupported pam_tid.so auth line"
    fi
}

verify_password_fallback_after_change() {
    if ! password_fallback_present; then
        fail_fast "$SUDO_PAM no longer contains required pam_opendirectory.so — refusing to leave system in this state"
    fi
}

verify_target_config() {
    local target="$1"

    if ! pam_tid_enabled_in "$target"; then
        fail_fast "Verification failed: pam_tid.so is not enabled in $target"
    fi

    validate_pam_file "$target" "$target"
    verify_password_fallback_after_change
}

install_pam_file() {
    local source="$1"
    local target="$2"

    validate_pam_file "$source" "temporary PAM config"
    install -m 644 -o root -g wheel "$source" "$target"
}

require_root_shell() {
    if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
        echo
        log_error "This command must be run from a root shell"
        log_info "Start a root shell first, then run make again:"
        echo "  sudo -s"
        echo "  make enable-sudo-touchid"
        echo
        fail_fast "Refusing to modify PAM config without an active root shell"
    fi
}

check_prerequisites() {
    log_step "Checking prerequisites"

    require_root_shell

    if ! is_macos; then
        fail_fast "Touch ID sudo is only available on macOS"
    fi

    if [[ ! -f "$SUDO_PAM" ]]; then
        fail_fast "PAM sudo config not found: $SUDO_PAM"
    fi

    if ! command_exists sudo; then
        fail_fast "sudo is required to configure Touch ID authentication"
    fi

    if ! pam_tid_module_exists; then
        fail_fast "Touch ID PAM module not found in $PAM_DIR (pam_tid.so / pam_tid.so.2)"
    fi

    if ! password_fallback_present; then
        fail_fast "$SUDO_PAM is missing pam_opendirectory.so — will not modify PAM config"
    fi

    if pam_tid_required_in "$SUDO_PAM" || pam_tid_required_in "$SUDO_LOCAL"; then
        fail_fast "Found required/requisite pam_tid.so — fix manually before enabling (can cause lockout)"
    fi

    if uses_sudo_local && ! sudo_local_include_present; then
        fail_fast "$SUDO_PAM does not include sudo_local despite template being present"
    fi

    if [[ -f "$SUDO_LOCAL_TEMPLATE" ]] && \
       ! grep -qE '^[[:space:]]*#auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$SUDO_LOCAL_TEMPLATE" && \
       ! grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$SUDO_LOCAL_TEMPLATE"; then
        log_warning "Apple template does not contain the expected pam_tid line — will append manually if needed"
    fi

    log_success "Prerequisites check completed"
}

show_safety_warning() {
    echo
    log_warning "Safety checklist:"
    echo "  - You are in a root shell (required)"
    echo "  - Keep this shell open until you verify sudo works in another terminal"
    echo "  - If anything breaks, recovery options from this shell:"
    echo "      cp ${SUDO_LOCAL}.backup.* $SUDO_LOCAL"
    echo "      rm $SUDO_LOCAL"
    echo "      open /etc/pam.d"
    echo "  - After changes, test in another terminal: sudo -k && sudo true"
    echo
}

confirm_proceed() {
    local mode="$1"

    if [[ "$SKIP_CONFIRM" == "1" ]]; then
        return 0
    fi

    show_safety_warning

    if [[ "$mode" == "direct" ]]; then
        log_warning "This Mac uses the legacy path (editing $SUDO_PAM directly)."
        log_warning "Prefer upgrading to Sonoma+ or edit manually using sudo_local if available."
    fi

    read -r -p "Proceed with Touch ID sudo configuration? (y/N): " reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log_info "Cancelled — no changes made"
        exit 0
    fi
}

build_sudo_local_config() {
    local dest
    dest="$(mktemp)"

    if [[ -f "$SUDO_LOCAL" ]]; then
        cp "$SUDO_LOCAL" "$dest"
    else
        cp "$SUDO_LOCAL_TEMPLATE" "$dest"
    fi

    if grep -qE '^[[:space:]]*#auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$dest"; then
        sed -i '' 's/^[[:space:]]*#auth[[:space:]]\{1,\}sufficient[[:space:]]\{1,\}pam_tid\.so/auth       sufficient     pam_tid.so/' "$dest"
    elif ! pam_tid_enabled_in "$dest"; then
        printf '%s\n' "$PAM_TID_LINE" >> "$dest"
    fi

    echo "$dest"
}

build_sudo_direct_config() {
    local dest
    dest="$(mktemp)"
    cp "$SUDO_PAM" "$dest"

    if ! pam_tid_enabled_in "$dest"; then
        awk -v line="$PAM_TID_LINE" '
            NR == 1 { print; print line; next }
            { print }
        ' "$dest" > "${dest}.new"
        mv "${dest}.new" "$dest"
    fi

    echo "$dest"
}

enable_via_sudo_local() {
    log_step "Configuring Touch ID via $SUDO_LOCAL"

    set_rollback_point "$SUDO_LOCAL"

    local temp_config
    temp_config="$(build_sudo_local_config)"
    verify_target_config "$temp_config"
    install_pam_file "$temp_config" "$SUDO_LOCAL"
    rm -f "$temp_config"

    ROLLBACK_FILE=""
    ROLLBACK_TARGET=""
    log_success "Touch ID enabled in $SUDO_LOCAL"
}

enable_via_sudo_direct() {
    log_step "Configuring Touch ID via $SUDO_PAM"

    set_rollback_point "$SUDO_PAM"

    local temp_config
    temp_config="$(build_sudo_direct_config)"
    verify_target_config "$temp_config"
    install_pam_file "$temp_config" "$SUDO_PAM"
    rm -f "$temp_config"

    ROLLBACK_FILE=""
    ROLLBACK_TARGET=""
    log_success "Touch ID enabled in $SUDO_PAM"
}

attempt_sudo_smoke_test() {
    log_step "Running sudo smoke test"

    if sudo -n true 2>/dev/null; then
        log_success "sudo smoke test passed (cached credentials)"
        return 0
    fi

    log_warning "Could not run non-interactive sudo test (no cached credentials)"
    log_info "Verify manually before closing any open root shell: sudo -k && sudo true"
}

disable_touchid() {
    print_header "Disable Touch ID for sudo"

    if ! is_macos; then
        fail_fast "Touch ID sudo is only available on macOS"
    fi

    require_root_shell

    local changed=false

    if [[ -f "$SUDO_LOCAL" ]] && pam_tid_enabled_in "$SUDO_LOCAL"; then
        set_rollback_point "$SUDO_LOCAL"
        local temp_config
        temp_config="$(mktemp)"
        cp "$SUDO_LOCAL" "$temp_config"
        sed -i '' 's/^\([[:space:]]*\)auth[[:space:]]\{1,\}sufficient[[:space:]]\{1,\}pam_tid\.so/\1#auth       sufficient     pam_tid.so/' "$temp_config"
        install_pam_file "$temp_config" "$SUDO_LOCAL"
        rm -f "$temp_config"
        ROLLBACK_FILE=""
        ROLLBACK_TARGET=""
        changed=true
        log_success "Disabled Touch ID in $SUDO_LOCAL"
    fi

    if pam_tid_enabled_in "$SUDO_PAM"; then
        set_rollback_point "$SUDO_PAM"
        local temp_config
        temp_config="$(mktemp)"
        grep -vE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$SUDO_PAM" > "$temp_config"
        install_pam_file "$temp_config" "$SUDO_PAM"
        rm -f "$temp_config"
        ROLLBACK_FILE=""
        ROLLBACK_TARGET=""
        changed=true
        log_success "Removed Touch ID from $SUDO_PAM"
    fi

    if [[ "$changed" != "true" ]]; then
        log_info "Touch ID for sudo is not enabled — nothing to disable"
    else
        verify_password_fallback_after_change
        print_footer "Touch ID for sudo disabled — password auth unchanged"
    fi
}

show_next_steps() {
    log_info "Touch ID is configured with password fallback (PAM 'sufficient' flag)"
    echo
    log_info "Test in a new terminal: sudo -k && sudo true"
    log_info "If Touch ID is unavailable, sudo will prompt for your password"
    echo
    log_info "To revert: make revert-sudo-touchid"
    echo
    log_info "iTerm2 users: disable 'Allow sessions to survive logging out and back in'"
    log_info "  (Prefs → Profiles → Session, or Advanced search for the setting)"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --yes|-y)
                SKIP_CONFIRM=1
                shift
                ;;
            --disable|-d)
                DISABLE=1
                shift
                ;;
            *)
                fail_fast "Unknown option: $1 (use --yes or --disable)"
                ;;
        esac
    done
}

main() {
    DISABLE=0
    parse_args "$@"

    if [[ "$DISABLE" == "1" ]]; then
        disable_touchid
        return 0
    fi

    check_prerequisites

    if touchid_already_enabled; then
        log_success "Touch ID for sudo is already enabled"
        show_next_steps
        print_footer "No changes needed"
        trap - EXIT
        return 0
    fi

    if uses_sudo_local; then
        confirm_proceed "sudo_local"
        enable_via_sudo_local
        verify_target_config "$SUDO_LOCAL"
    else
        confirm_proceed "direct"
        enable_via_sudo_direct
        verify_target_config "$SUDO_PAM"
    fi
    attempt_sudo_smoke_test
    show_next_steps
    print_footer "Touch ID for sudo enabled!"
    trap - EXIT
}

main "$@"
