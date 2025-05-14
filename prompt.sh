#!/bin/bash


# Returns the current kubernetes context and namespace if kubectl is available
kubernetes_context() {
    if command -v kubectl &> /dev/null && context=$(kubectl config current-context 2> /dev/null); then
        if [[ "$context" == */* ]]; then
            context=${context##*/}
        fi
        echo " [k8s: ${context}:$(kubens -c)]"
    else
        echo ""
    fi
}

# Returns the current git branch if in a git repository
git_branch() {
    local branch=$(git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$branch" ]; then
        echo " [${branch}]"
    fi
}

# Builds and sets the prompt string
prompt_command() {
    local exit="$?"
    local prompt=""

    # Build the main prompt line
    prompt="\[${red}\]\u\[${end}\] \[${lightblue}\]\w\[${end}\]"
    prompt+="\[${blueb}\]\$(git_branch)\[${end}\]"
    prompt+="\[${greenb}\]\$(kubernetes_context)\[${end}\]"

    # Add error code if last command failed
    if [ $exit != 0 ]; then
        prompt+="\n[exit: \[${red}\]${exit}\[${end}\]]"
    fi

    # Add final prompt character
    prompt+="\n\[${blackb}\]$\[${end}\] "

    PS1="${prompt}"
}

PROMPT_COMMAND=prompt_command
