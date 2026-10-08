#!/usr/bin/env bash
# Starts ComfyUI from the mk0002/gen image.
#
# Two ways in, one script:
#   local / self-hosted:  the image ENTRYPOINT. ComfyUI runs in the foreground.
#   Vast (SSH launch):    Vast replaces the entrypoint with its own sshd, so its
#                         on-start script runs `/opt/mk0002/start.sh --background`.
#
# Env: COMFY_LISTEN (127.0.0.1), COMFY_PORT (18188), WORKSPACE (/workspace),
#      COMFY_CPU=1 to run without a GPU (smoke tests only).
set -euo pipefail

W="${WORKSPACE:-/workspace}"
mkdir -p "$W/models" "$W/output"
# Recreate ComfyUI's model folder layout on an empty volume (dirs only).
(cd /opt/ComfyUI/models.dist && find . -type d -exec mkdir -p "$W/models/{}" \;)

# Re-arm the idle auto-stop on EVERY start, not just `gpu up`'s. Vast can start
# a box by itself: a start queued while the GPU was rented out went through
# unattended and billed ~27 min with no auto-stop (llm-s, 2026-10-07). The
# script is put there by the first `gpu up`, and --start replaces a running copy.
if [ -f /root/.gpu_idle/idle_stop.sh ]; then
  bash /root/.gpu_idle/idle_stop.sh --start > "$W/.gpu_idle_rearm.log" 2>&1 || echo "WARNING: idle auto-stop re-arm failed (see $W/.gpu_idle_rearm.log)"
fi

args=(main.py --listen "${COMFY_LISTEN:-127.0.0.1}" --port "${COMFY_PORT:-18188}")
if [ -n "${COMFY_CPU:-}" ]; then args+=(--cpu); fi

cd /opt/ComfyUI
if [ "${1:-}" = "--background" ]; then
  # Same pidfile and log path bootstrap.sh uses, so `gpu-gen setup` can
  # restart this process to load new nodes.
  nohup python3 "${args[@]}" > "$W/comfyui.log" 2>&1 &
  echo $! > "$W/.gpu_gen_comfy.pid"
  echo "MK0002_START role=gen pid=$! port=${COMFY_PORT:-18188}"
  exit 0
fi
exec python3 "${args[@]}"
