#!/bin/bash

###############################################################################
# Interactive Ollama model selection (fzf)
#
# Prints selected model tags (space-separated) on stdout.
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG="$SCRIPT_DIR/llm-models.catalog"
PRESELECTED=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --preselected)
            PRESELECTED="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: setup-llm-select.sh [--preselected \"model1 model2\"]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# shellcheck source=lib/setup-utils.sh
source "$DOTFILES_ROOT/lib/setup-utils.sh"
# shellcheck source=lib/llm-hardware.sh
source "$DOTFILES_ROOT/lib/llm-hardware.sh"
# shellcheck source=lib/llm-compat.sh
source "$DOTFILES_ROOT/lib/llm-compat.sh"
# shellcheck source=setup/llm.defaults.sh
source "$SCRIPT_DIR/llm.defaults.sh"

require_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        return 0
    fi
    if [[ -x /opt/homebrew/bin/fzf ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        return 0
    fi
    if [[ -x /usr/local/bin/fzf ]]; then
        export PATH="/usr/local/bin:$PATH"
        return 0
    fi
    fail_fast "fzf is required. Install with: brew install fzf"
}

build_fzf_lines() {
    local tag param_b ram_min ram_comfort category desc score marker label hint

    llm_hardware_summary

    while IFS=$'\t' read -r tag param_b ram_min ram_comfort category desc; do
        [[ -z "$tag" || "$tag" == \#* ]] && continue
        [[ "$tag" == "tag" ]] && continue

        score="$(llm_compat_score "$ram_min" "$ram_comfort" "$LLM_RAM_AVAILABLE_GB")"
        marker="$(llm_compat_marker "$score")"
        label="$(llm_compat_label "$score")"
        hint="$(llm_compat_color_hint "$score")"

        printf '%s\t%s\t%s\t%-22s\t%4sB\t%5sGB\t%-10s\t%s\t%s\n' \
            "$tag" "$marker" "$label" "$tag" "$param_b" "$ram_min" "$category" "$desc" "$hint"
    done < "$CATALOG"
}

warn_combined_ram() {
    local -a tags=("$@")
    local combined_min=0 tag ctag cmin

    for tag in "${tags[@]}"; do
        while IFS=$'\t' read -r ctag _ cmin _ _ _; do
            [[ "$ctag" == "$tag" ]] || continue
            combined_min=$((combined_min + cmin))
            break
        done < "$CATALOG"
    done

    if [[ "$combined_min" -gt "$LLM_RAM_AVAILABLE_GB" ]]; then
        log_warning "Selected models sum to ~${combined_min}GB minimum; ~${LLM_RAM_AVAILABLE_GB}GB is available."
        log_warning "Ollama runs one model at a time — OK if you do not load all at once."
        read -r -p "Continue? [y/N] " reply
        [[ "$reply" =~ ^[Yy]$ ]] || exit 1
    fi
}

run_fzf_picker() {
    local header lines selected

    llm_hardware_summary

    header="Select models (Tab=multi, Enter=confirm) · ${LLM_CPU_LABEL} · ${LLM_RAM_TOTAL_GB}GB RAM · ~${LLM_RAM_AVAILABLE_GB}GB for LLMs · ● excellent ◐ good ◔ marginal ✗ unsuitable"

    lines="$(build_fzf_lines)"
    [[ -n "$lines" ]] || fail_fast "Model catalog is empty: $CATALOG"

    local fzf_args=(
        --multi
        --delimiter=$'\t'
        --with-nth=2..8
        --header="$header"
        --height=85%
        --border=rounded
        --prompt="Models> "
        --pointer="▶"
        --marker="✓ "
        --bind="ctrl-a:select-all"
        --bind="ctrl-d:deselect-all"
        --preview="$SCRIPT_DIR/llm-fzf-preview.sh {}"
        --preview-window=right:50%:wrap
        --layout=reverse-list
    )

    if [[ -n "$PRESELECTED" ]]; then
        fzf_args+=(--query "$PRESELECTED")
    fi

    selected="$(printf '%s\n' "$lines" | fzf "${fzf_args[@]}")" || {
        log_warning "Model selection cancelled"
        exit 1
    }

    [[ -n "$selected" ]] || fail_fast "No models selected"

    local -a tags=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        tags+=("${line%%$'\t'*}")
    done <<< "$selected"

    warn_combined_ram "${tags[@]}"
    echo "${tags[*]}"
}

main() {
    require_fzf
    [[ -f "$CATALOG" ]] || fail_fast "Missing catalog: $CATALOG"
    run_fzf_picker
}

main "$@"
