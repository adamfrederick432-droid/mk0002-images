# mk0002/gen -- ComfyUI plus the custom nodes gpu-gen uses (GPU fleet plan, Phase 3).
#
# Weights and outputs are NOT in the image. /opt/ComfyUI/models and /output are
# symlinks into /workspace, which is the Vast instance disk or a local
# `-v <volume>:/workspace`. bootstrap.sh's downloads therefore land on that
# volume and survive an image rebuild.
#
# CUDA 12.8: the oldest line with RTX 5090 (sm_120) kernels. CUDA 13 needs
# driver 580+, which many Vast hosts don't run yet.
FROM pytorch/pytorch:2.11.0-cuda12.8-cudnn9-runtime

ARG COMFY_REF=v0.39.0
ARG MANAGER_SHA=e848c5edf7d33e3497512dce779df59373f5fa0c
ARG RIFE_SHA=26545cc2dd95bc3d27f056016300673bdeee78f5
ARG MMAUDIO_SHA=8eaeb72edc3aaf2059b57f2d96a1f6f689f19ae2
ARG IPADAPTER_SHA=a0f451a5113cf9becb0847b92884cb10cbdec0ef

RUN apt-get update \
 && apt-get install -y --no-install-recommends git curl ca-certificates ffmpeg \
      libgl1 libglib2.0-0 procps zstd \
 && rm -rf /var/lib/apt/lists/*

# The 2.11 base marks its Python as externally managed (PEP 668), and pip refuses
# to install into it. This container has one purpose, so allow it for the build
# and for bootstrap.sh's own pip installs on the box. The first CI build
# (2026-10-08) failed here without it.
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Fail early and say why if python3 isn't the interpreter that has CUDA torch.
# Every later step, start.sh and bootstrap.sh all run `python3`.
RUN python3 -c "import torch; print('torch', torch.__version__, 'cuda', torch.version.cuda)" \
 && python3 -c "import torch, sys; sys.exit(0 if torch.version.cuda else 'torch has no CUDA build')"

RUN git clone --depth 1 --branch "$COMFY_REF" https://github.com/comfyanonymous/ComfyUI /opt/ComfyUI \
 && python3 -m pip install --no-cache-dir -r /opt/ComfyUI/requirements.txt

# Same four nodes bootstrap.sh installs, pinned to a commit so two builds match.
# install_node in bootstrap.sh skips a node dir that already exists.
COPY install_node.sh /opt/mk0002/install_node.sh
RUN bash /opt/mk0002/install_node.sh ComfyUI-Manager https://github.com/ltdrdata/ComfyUI-Manager "$MANAGER_SHA" requirements.txt \
 && bash /opt/mk0002/install_node.sh ComfyUI-Frame-Interpolation https://github.com/Fannovel16/ComfyUI-Frame-Interpolation "$RIFE_SHA" requirements-no-cupy.txt \
 && bash /opt/mk0002/install_node.sh ComfyUI-MMAudio https://github.com/kijai/ComfyUI-MMAudio "$MMAUDIO_SHA" requirements.txt \
 && bash /opt/mk0002/install_node.sh ComfyUI_IPAdapter_plus https://github.com/cubiq/ComfyUI_IPAdapter_plus "$IPADAPTER_SHA"

# Weights and outputs live on the volume. models.dist keeps ComfyUI's folder
# layout so start.sh can recreate it on an empty volume.
RUN mv /opt/ComfyUI/models /opt/ComfyUI/models.dist \
 && ln -s /workspace/models /opt/ComfyUI/models \
 && rm -rf /opt/ComfyUI/output && ln -s /workspace/output /opt/ComfyUI/output

COPY start.sh /opt/mk0002/start.sh
RUN chmod 755 /opt/mk0002/*.sh

# Loopback by default: on Vast it is reached through the SSH tunnel, never a
# public port. A local smoke test overrides COMFY_LISTEN=0.0.0.0.
ENV MK0002_ROLE=gen \
    COMFY_LISTEN=127.0.0.1 \
    COMFY_PORT=18188 \
    WORKSPACE=/workspace
EXPOSE 18188
LABEL org.opencontainers.image.title="mk0002/gen" \
      org.opencontainers.image.description="ComfyUI ${COMFY_REF} + gpu-gen nodes; weights on /workspace"

ENTRYPOINT ["/opt/mk0002/start.sh"]
