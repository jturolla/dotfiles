#!/bin/bash

# Initialize command line argument parsing using docopts
#
# Usage:
#   init_cli "script_path" "help_text"
#
# Arguments:
#   script_path: Path to the script being executed (usually $0)
#   help_text: Optional help text. If not provided, will be extracted from script comments
init_cli() {
    local script_path="$1"
    local help_text="${2:-}"

    # Source docopts installation function
    source "$(dirname "$script_path")/lib/docopts.sh"

    # Ensure docopts is installed
    ensure_docopts

    # If no help text provided, extract it from script comments
    if [ -z "$help_text" ]; then
        help_text="$(sed -n '/^###/,/^###/p' "$script_path" | grep "^#" | grep -v "^###" | cut -c 3-)"
    fi

    # Parse and evaluate arguments
    eval "$(docopts -h "$help_text" : "${@:3}")"
}