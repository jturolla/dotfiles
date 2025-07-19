#!/bin/bash

# Setup Utilities Library
# Provides colorful logging and common functions for dotfiles setup scripts

set -euo pipefail

# Source colors for consistency
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

# Global variables
SCRIPT_NAME="${0##*/}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Logging functions
log_info() {
    echo -e "$(green "ℹ️  [$SCRIPT_NAME]") $*"
}

log_success() {
    echo -e "$(greenb "✅ [$SCRIPT_NAME]") $*"
}

log_warning() {
    echo -e "$(yellowb "⚠️  [$SCRIPT_NAME]") $*"
}

log_error() {
    echo -e "$(redb "❌ [$SCRIPT_NAME]") $*" >&2
}

log_debug() {
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        echo -e "$(blue "🐛 [$SCRIPT_NAME]") $*"
    fi
}

log_step() {
    echo -e "$(blueb "🔧 [$SCRIPT_NAME]") $*"
}

# Progress indicator
show_progress() {
    local message="$1"
    echo -e "$(lightblueb "⏳ [$SCRIPT_NAME]") $message..."
}

# Error handling
fail_fast() {
    local message="$1"
    log_error "$message"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if file exists and is readable
file_readable() {
    [[ -f "$1" && -r "$1" ]]
}

# Check if directory exists and is writable
dir_writable() {
    [[ -d "$1" && -w "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_step "Creating directory: $dir"
        mkdir -p "$dir" || fail_fast "Failed to create directory: $dir"
    fi
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d-%H%M%S)"
        log_step "Backing up existing file: $file -> $backup"
        cp "$file" "$backup" || fail_fast "Failed to backup file: $file"
    fi
}

# Create symbolic link with backup
safe_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -f "$source" ]]; then
        fail_fast "Source file does not exist: $source"
    fi
    
    # Backup existing file
    backup_file "$target"
    
    # Remove existing file/link
    if [[ -e "$target" || -L "$target" ]]; then
        rm -f "$target"
    fi
    
    # Create symlink
    ln -sf "$source" "$target" || fail_fast "Failed to create symlink: $source -> $target"
    log_success "Linked: $source -> $target"
}

# Download file with retries
download_file() {
    local url="$1"
    local output="$2"
    local retries="${3:-3}"
    
    for ((i=1; i<=retries; i++)); do
        if curl -fsSL "$url" -o "$output"; then
            log_success "Downloaded: $url -> $output"
            return 0
        else
            log_warning "Download attempt $i failed: $url"
            if [[ $i -eq $retries ]]; then
                fail_fast "Failed to download after $retries attempts: $url"
            fi
            sleep 2
        fi
    done
}

# Check if system is macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Check if system is Linux
is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Get OS distribution (for Linux)
get_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check if running with sudo
is_sudo() {
    [[ $EUID -eq 0 ]]
}

# Validate required environment variables
validate_required_vars() {
    local vars=("$@")
    local missing=()
    
    for var in "${vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing+=("$var")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required environment variables:"
        for var in "${missing[@]}"; do
            log_error "  - $var"
        done
        fail_fast "Please set the missing variables in .setupconf"
    fi
}

# Check system requirements
check_system_requirements() {
    local os_supported=false
    
    if is_macos; then
        log_info "Detected macOS system"
        os_supported=true
    elif is_linux; then
        log_info "Detected Linux system ($(get_linux_distro))"
        os_supported=true
    fi
    
    if [[ "$os_supported" != "true" ]]; then
        fail_fast "Unsupported operating system: $OSTYPE"
    fi
}

# Install package with OS-specific package manager
install_package() {
    local package="$1"
    local description="${2:-$package}"
    
    log_step "Installing $description..."
    
    if is_macos; then
        if command_exists brew; then
            brew install "$package" || log_warning "Failed to install $package via brew"
        else
            fail_fast "Homebrew is required but not installed"
        fi
    elif is_linux; then
        local distro
        distro=$(get_linux_distro)
        case "$distro" in
            ubuntu|debian)
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install -y "$package" || log_warning "Failed to install $package via apt"
                ;;
            *)
                log_warning "Unknown Linux distribution: $distro"
                ;;
        esac
    fi
}

# Check if package is installed
package_installed() {
    local package="$1"
    
    if is_macos; then
        brew list "$package" >/dev/null 2>&1
    elif is_linux; then
        dpkg -l "$package" >/dev/null 2>&1
    else
        false
    fi
}

# Print script header
print_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title} - 4) / 2 ))
    
    echo
    echo -e "$(blueb "$(printf '=%.0s' $(seq 1 $width))")"
    echo -e "$(blueb "$(printf '%*s' $padding)") $(whiteb "$title") $(blueb "$(printf '%*s' $padding)")"
    echo -e "$(blueb "$(printf '=%.0s' $(seq 1 $width))")"
    echo
}

# Print script footer
print_footer() {
    local message="${1:-Setup completed successfully!}"
    echo
    log_success "$message"
    echo
}

# Cleanup function to be called on script exit
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
    fi
}

# Set up trap for cleanup
trap cleanup EXIT 