#!/usr/bin/env bash
# Starts Ollama from the mk0002/llm image. The same two ways in as gen/start.sh:
# the foreground ENTRYPOINT locally, or `--background` from Vast's on-start script.
set -euo pipefail

W="${WORKSPACE:-/workspace}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-$W/ollama}"
mkdir -p "$OLLAMA_MODELS"

if [ "${1:-}" = "--background" ]; then
  # Same log path llm_bootstrap.sh uses.
  nohup ollama serve > "$W/ollama.log" 2>&1 &
  echo "MK0002_START role=llm pid=$! host=$OLLAMA_HOST"
  exit 0
fi
exec ollama serve
