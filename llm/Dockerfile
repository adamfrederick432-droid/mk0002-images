# mk0002/llm -- Ollama, pinned (GPU fleet plan, Phase 3).
#
# Ollama rather than vLLM: the models are GGUFs (models.toml pulls hf.co/...:Q4_K_M),
# and vLLM's own docs list its GGUF support as limited. Ollama runs them on
# llama.cpp, which is what /gpu-research's llm-s spec picked.
#
# Models are NOT in the image. OLLAMA_MODELS points at /workspace, which is the
# Vast instance disk or a local `-v <volume>:/workspace`.
#
# Keep the tag equal to models.toml [llm] ollama_version. llm_bootstrap.sh
# reinstalls Ollama when the two differ.
FROM ollama/ollama:0.40.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates zstd procps \
 && rm -rf /var/lib/apt/lists/*

COPY start.sh /opt/mk0002/start.sh
RUN chmod 755 /opt/mk0002/start.sh

# Loopback by default (reached through the SSH tunnel). The base image sets
# 0.0.0.0. A local smoke test sets it back with -e OLLAMA_HOST=0.0.0.0:11434.
ENV MK0002_ROLE=llm \
    OLLAMA_HOST=127.0.0.1:11434 \
    OLLAMA_MODELS=/workspace/ollama \
    WORKSPACE=/workspace
EXPOSE 11434
LABEL org.opencontainers.image.title="mk0002/llm" \
      org.opencontainers.image.description="Ollama 0.40.0; models on /workspace/ollama"

ENTRYPOINT ["/opt/mk0002/start.sh"]
