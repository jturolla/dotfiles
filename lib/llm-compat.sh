#!/bin/bash
# Compatibility scoring for Ollama models vs detected hardware

# llm_compat_score ram_min_gb ram_comfort_gb available_gb -> excellent|good|marginal|unsuitable
llm_compat_score() {
    local ram_min="$1"
    local ram_comfort="$2"
    local avail="$3"

    if [[ "$avail" -lt "$ram_min" ]]; then
        echo "unsuitable"
        return
    fi

    if [[ "$avail" -ge "$ram_comfort" ]]; then
        echo "excellent"
        return
    fi

    if [[ "$avail" -ge "$ram_min" ]]; then
        # Between minimum and comfortable
        local gap=$((ram_comfort - avail))
        if [[ "$gap" -le 2 ]]; then
            echo "good"
        else
            echo "marginal"
        fi
        return
    fi

    echo "unsuitable"
}

llm_compat_label() {
    case "$1" in
        excellent) echo "EXCELLENT" ;;
        good)      echo "GOOD     " ;;
        marginal)  echo "MARGINAL " ;;
        unsuitable) echo "UNSUITABLE" ;;
        *)         echo "UNKNOWN  " ;;
    esac
}

llm_compat_marker() {
    case "$1" in
        excellent) echo "●" ;;
        good)      echo "◐" ;;
        marginal)  echo "◔" ;;
        unsuitable) echo "✗" ;;
        *)         echo "?" ;;
    esac
}

llm_compat_color_hint() {
    case "$1" in
        excellent) echo "fits comfortably" ;;
        good)      echo "should run well" ;;
        marginal)  echo "tight — close other apps" ;;
        unsuitable) echo "exceeds available RAM" ;;
    esac
}
