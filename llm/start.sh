#!/usr/bin/env bash
# Starts Ollama from the mk0002/llm image. The same two ways in as gen/start.sh:
# the foreground ENTRYPOINT locally, or `--background` from Vast's on-start script.
set -euo pipefail

W="${WORKSPACE:-/workspace}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-$W/ollama}"
mkdir -p "$OLLAMA_MODELS"

# Re-arm the idle auto-stop on EVERY start, not just `gpu up`'s. Vast can start
# a box by itself: a start queued while the GPU was rented out went through
# unattended and billed ~27 min with no auto-stop (llm-s, 2026-10-07). The
# script is put there by the first `gpu up`, and --start replaces a running copy.
if [ -f /root/.gpu_idle/idle_stop.sh ]; then
  bash /root/.gpu_idle/idle_stop.sh --start > "$W/.gpu_idle_rearm.log" 2>&1 || echo "WARNING: idle auto-stop re-arm failed (see $W/.gpu_idle_rearm.log)"
fi

if [ "${1:-}" = "--background" ]; then
  # Same log path llm_bootstrap.sh uses.
  nohup ollama serve > "$W/ollama.log" 2>&1 &
  echo "MK0002_START role=llm pid=$! host=$OLLAMA_HOST"
  exit 0
fi
exec ollama serve
