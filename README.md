# mk0002 fleet images

Portable images for the MK0002 GPU fleet. The source of truth is
`moats/gpu/images` in MK0002 OS, and `roles.toml` there names the tags.

| Image | What | Port (loopback) | Weights |
|---|---|---|---|
| `mk0002-gen` | ComfyUI v0.39.0 + gpu-gen's 4 custom nodes, pinned | 18188 | `/workspace/models` |
| `mk0002-llm` | Ollama 0.40.0 | 11434 | `/workspace/ollama` |

Nothing heavy is baked in. Mount `/workspace` and the weights stay there
across image rebuilds.

**Vast (SSH launch):** Vast replaces the entrypoint with its own sshd, so set
the template's on-start script to

    /opt/mk0002/start.sh --background

**Local / self-hosted (NVIDIA):**

    docker run --gpus all -v gen-weights:/workspace -p 127.0.0.1:18188:18188 -e COMFY_LISTEN=0.0.0.0 ghcr.io/<owner>/mk0002-gen:0.39.0
    docker run --gpus all -v llm-weights:/workspace -p 127.0.0.1:11434:11434 -e OLLAMA_HOST=0.0.0.0:11434 ghcr.io/<owner>/mk0002-llm:0.40.0

The `127.0.0.1:` in `-p` keeps the service off the LAN. Inside the container
it has to listen on 0.0.0.0 for Docker's port mapping to reach it.

CI (`.github/workflows/build.yml`) builds both, pushes them to GHCR and
CPU-smoke-tests each one.
