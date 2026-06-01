#!/bin/bash
# Hardware detection for local LLM compatibility

llm_detect_total_ram_gb() {
    local bytes=0

    if [[ "$OSTYPE" == darwin* ]]; then
        bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
    elif [[ -r /proc/meminfo ]]; then
        local kb
        kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
        bytes=$((kb * 1024))
    fi

    if [[ "$bytes" -le 0 ]]; then
        echo "16"
        return
    fi

    echo $(( (bytes + 536870911) / 1073741824 ))
}

llm_detect_cpu_label() {
    if [[ "$OSTYPE" == darwin* ]]; then
        sysctl -n machdep.cpu.brand_string 2>/dev/null || uname -m
    else
        grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //' || uname -m
    fi
}

llm_detect_accelerator() {
    if [[ "$OSTYPE" == darwin* ]] && [[ "$(uname -m)" == "arm64" ]]; then
        echo "apple-silicon"
    elif [[ "$OSTYPE" == darwin* ]]; then
        echo "mac-intel"
    elif command -v nvidia-smi >/dev/null 2>&1; then
        echo "nvidia"
    else
        echo "cpu"
    fi
}

# RAM reserved for macOS / desktop overhead before LLM inference
llm_system_reserve_gb() {
    local total_gb="$1"
    if [[ "$OSTYPE" == darwin* ]]; then
        if [[ "$total_gb" -ge 32 ]]; then
            echo 6
        else
            echo 4
        fi
    else
        if [[ "$total_gb" -ge 32 ]]; then
            echo 4
        else
            echo 2
        fi
    fi
}

llm_hardware_summary() {
    local total_gb avail_gb reserve_gb cpu accel

    total_gb="$(llm_detect_total_ram_gb)"
    reserve_gb="$(llm_system_reserve_gb "$total_gb")"
    avail_gb=$((total_gb - reserve_gb))
    if [[ "$avail_gb" -lt 2 ]]; then
        avail_gb=2
    fi

    cpu="$(llm_detect_cpu_label)"
    accel="$(llm_detect_accelerator)"

    LLM_RAM_TOTAL_GB="$total_gb"
    LLM_RAM_AVAILABLE_GB="$avail_gb"
    LLM_RAM_RESERVE_GB="$reserve_gb"
    LLM_CPU_LABEL="$cpu"
    LLM_ACCELERATOR="$accel"

    export LLM_RAM_TOTAL_GB LLM_RAM_AVAILABLE_GB LLM_RAM_RESERVE_GB LLM_CPU_LABEL LLM_ACCELERATOR
}
