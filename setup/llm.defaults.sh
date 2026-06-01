#!/bin/bash
# Local LLM defaults (ports, paths). Override ports in .setupconf if needed.

# Deterministic service ports (127.0.0.1)
LLM_OLLAMA_HOST="${LLM_OLLAMA_HOST:-127.0.0.1}"
LLM_OLLAMA_PORT="${LLM_OLLAMA_PORT:-11434}"

# OpenAI-compatible API is served by Ollama on the same host/port at /v1
LLM_OPENAI_PORT="${LLM_OPENAI_PORT:-11434}"

# Reserved for optional future local services (not started by make llm)
LLM_PORT_OPEN_WEBUI="${LLM_PORT_OPEN_WEBUI:-8080}"
LLM_PORT_LMSTUDIO="${LLM_PORT_LMSTUDIO:-1234}"

LLM_OLLAMA_HOSTPORT="${LLM_OLLAMA_HOST}:${LLM_OLLAMA_PORT}"
LLM_API_BASE="http://${LLM_OLLAMA_HOSTPORT}"
LLM_OPENAI_BASE="http://${LLM_OLLAMA_HOSTPORT}/v1"

# Fallback models when non-interactive and OLLAMA_MODELS unset
DEFAULT_OLLAMA_MODELS="qwen2.5:14b llama3.2:3b"

LLM_CONFIG_DIR="${HOME}/.config/dotfiles"
LLM_ENV_FILE="${LLM_CONFIG_DIR}/llm.env"
LLM_MODELS_FILE="${LLM_CONFIG_DIR}/llm.models"
