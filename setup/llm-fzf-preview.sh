#!/bin/bash
# fzf --preview helper for setup-llm-select.sh
set -euo pipefail

line="${1:-}"
tag="${line%%$'\t'*}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/llm-hardware.sh
source "$DOTFILES_ROOT/lib/llm-hardware.sh"
# shellcheck source=lib/llm-compat.sh
source "$DOTFILES_ROOT/lib/llm-compat.sh"

CATALOG="$SCRIPT_DIR/llm-models.catalog"
llm_hardware_summary

ram_min="" ram_comfort="" category="" desc=""
while IFS=$'\t' read -r ctag _ cmin ccomfort ccat cdesc; do
    [[ "$ctag" == "$tag" ]] || continue
    ram_min="$cmin"
    ram_comfort="$ccomfort"
    category="$ccat"
    desc="$cdesc"
    break
done < "$CATALOG"

if [[ -z "$ram_min" ]]; then
    echo "Unknown model: $tag"
    exit 0
fi

score="$(llm_compat_score "$ram_min" "$ram_comfort" "$LLM_RAM_AVAILABLE_GB")"

cat <<EOF
Model:      $tag
Category:   $category
RAM:        ${ram_min}GB min · ${ram_comfort}GB comfortable
Fit:        $(llm_compat_label "$score") — $(llm_compat_color_hint "$score")

This machine:
  CPU:        $LLM_CPU_LABEL
  Total RAM:  ${LLM_RAM_TOTAL_GB}GB (~${LLM_RAM_RESERVE_GB}GB reserved for OS)
  For LLMs:   ~${LLM_RAM_AVAILABLE_GB}GB
  Accel:      $LLM_ACCELERATOR

$desc
EOF
