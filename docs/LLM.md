# Local LLM architecture

## Canonical entrypoint

| Layer | What you use |
|-------|----------------|
| **CLI** | `llm` (`bin/llm`) — chat, ask, pick default model |
| **HTTP** | `LLM_OPENAI_BASE` → `http://127.0.0.1:11434/v1` |
| **Model ID** | Ollama tag per request, e.g. `qwen2.5:14b` |

Install many models; route by **model name in the request**, not by port.

```bash
llm list
llm pick                    # default model for -m-less usage
llm ask "hello" -m llama3.2:3b
```

IDEs (Cursor, Continue): `llm api` prints `OPENAI_API_BASE` and `OPENAI_API_KEY=ollama`.

## How this compares to Hugging Face

| Approach | Download | Serve | Pick model |
|----------|----------|-------|------------|
| **Ollama** (this repo) | `ollama pull tag` | One daemon :11434 | `"model"` in `/v1/chat/completions` |
| **HF Hub + transformers** | `huggingface-cli download` | Your Python process | `from_pretrained("org/name")` |
| **vLLM / TGI** | HF repo id | One server, OpenAI API | `"model"` in request (HF id) |
| **LiteLLM** | N/A (proxy) | One proxy port | Routes `model` string to Ollama/HF/OpenAI |

Hugging Face users typically:

1. **Library** — load weights in-process (`transformers`, `llama.cpp` Python).
2. **Server** — run **vLLM** or **Text Generation Inference** with `--model-id HuggingFaceH4/zephyr-7b-beta`, expose OpenAI-compatible `/v1`.
3. **GGUF on Hub** — download quantized files; run in Ollama or llama.cpp (Ollama often imports HF-derived weights as tags).

Ollama is closest to (2): one local OpenAI-compatible server, model string in each call. You do **not** need a separate port per model.

## Multiple models at once

Ollama loads **one model into memory at a time**; switching models unloads the previous. Disk holds all pulled models; RAM holds the active one. That matches most local setups unless you run multiple GPU processes (vLLM multi-model is advanced).

## Optional: unify HF + Ollama

[LiteLLM](https://github.com/BerriAI/litellm) proxy on a fixed port can route:

- `ollama/qwen2.5:14b`
- `huggingface/meta-llama/Llama-3.2-3B`

…through one `OPENAI_API_BASE`. Not installed by default; add if you need HF repo IDs alongside Ollama tags.
