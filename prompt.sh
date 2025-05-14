#!/bin/bash

# Special symbols for prompt segments
RIGHT_ARROW=$'\uE0B0'  # Unicode symbol for right-pointing triangle
RIGHT_SEP=$'\uE0B0'    # Unicode symbol for right separator
LEFT_SEP=$'\uE0B2'     # Unicode symbol for left separator
GIT_SYMBOL=$'\uE0A0'   # Git branch symbol
KUBERNETES_SYMBOL='⎈'   # Kubernetes symbol

# Returns the current kubernetes context and namespace if kubectl is available
kubernetes_context() {
    # Check for yaml files with 'kind' in the current directory
    local has_kube_yaml=false
    while IFS= read -r -d '' file; do
        if grep -q "kind:" "$file" 2>/dev/null; then
            has_kube_yaml=true
            break
        fi
    done < <(find . -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \) -print0 2>/dev/null)

    if [ "$has_kube_yaml" = false ]; then
        return
    fi

    if command -v kubectl &> /dev/null && context=$(kubectl config current-context 2> /dev/null); then
        if [[ "$context" == */* ]]; then
            context=${context##*/}
        fi
        echo -n " ${KUBERNETES_SYMBOL} ${context}:$(kubens -c) "
    fi
}

# Returns the current git branch and status
git_branch() {
    if ! command -v git &> /dev/null; then
        return
    fi

    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        return
    fi

    local branch
    branch=$(git symbolic-ref --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null)
    if [ -n "$branch" ]; then
        # Check if there are any changes
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            __git_status="dirty"
        else
            __git_status="clean"
        fi
        echo -n " ${branch} "
    fi
}

# Pre-command to store git branch and status
__prompt_precmd() {
    __git_branch="$(git_branch)"
    __git_status=${__git_status:-clean}
    # Force evaluation of git status
    if [ -n "$__git_branch" ]; then
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            __git_status="dirty"
        else
            __git_status="clean"
        fi
    fi
}

# Builds and sets the prompt string
prompt_command() {
    local exit="$?"
    local prompt=""

    # Run pre-command to get git info
    __prompt_precmd

    # Username segment (dark text on soft pink)
    prompt+="\[\e[30;48;5;218m\] \u "

    # Directory segment (bright text on dark gray)
    prompt+="\[\e[38;5;218;48;5;238m\]${RIGHT_SEP}\[\e[97m\] \w "

    # Git branch segment (colored text on dark grey depending on status)
    if [ -n "$__git_branch" ]; then
        # Add separator with dark grey background
        prompt+="\[\e[38;5;238;48;5;238m\]${RIGHT_SEP}"
        # Add git branch with appropriate color based on status
        if [ "$__git_status" = "dirty" ]; then
            prompt+="\[\e[1;38;5;203m\]${GIT_SYMBOL}${__git_branch}"  # Bold light red for dirty
        else
            prompt+="\[\e[1;38;5;120m\]${GIT_SYMBOL}${__git_branch}"  # Bold light green for clean
        fi
    fi

    # Kubernetes context segment (white text on blue)
    if [ -n "$(kubernetes_context)" ]; then
        prompt+="\[\e[38;5;238;48;5;33m\]${RIGHT_SEP}\[\e[97m\]"
        prompt+="\$(kubernetes_context)"
    fi

    # End the first line with a reset separator
    local last_color
    if [ -n "$(kubernetes_context)" ]; then
        last_color="33"
    elif [ -n "$__git_branch" ]; then
        last_color="238"
    else
        last_color="238"
    fi
    prompt+="\[\e[0m\]\[\e[38;5;${last_color}m\]${RIGHT_SEP}\[\e[0m\]"

    # Add error code if last command failed (white on soft red)
    if [ $exit != 0 ]; then
        prompt+="\n\[\e[97;48;5;196m\] ✘ ${exit} \[\e[0m\]\[\e[38;5;196m\]${RIGHT_SEP}\[\e[0m\]"
    fi

    # Add final prompt character on new line (light gray)
    prompt+="\n\[\e[38;5;246m\]$\[\e[0m\] "

    PS1="${prompt}"
}

PROMPT_COMMAND=prompt_command
