#!/usr/bin/env bash
# install_node.sh <dir-name> <repo-url> <commit-sha> [requirements-file]
# Build-time twin of bootstrap.sh's install_node, pinned to one commit.
set -euo pipefail
dest="/opt/ComfyUI/custom_nodes/$1"
git init -q "$dest"
git -C "$dest" remote add origin "$2"
git -C "$dest" fetch -q --depth 1 origin "$3"
git -C "$dest" checkout -q FETCH_HEAD
rm -rf "$dest/.git"
if [ -n "${4:-}" ] && [ -f "$dest/$4" ]; then
  pip install --no-cache-dir -r "$dest/$4"
fi
