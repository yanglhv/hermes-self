#!/usr/bin/env sh
# install.sh — BootOpenFlow hermes-self installer
#
# Detects upstream project manifest and runs the appropriate install command.
# Always exits 0 (placeholder-friendly: never blocks the launcher even if the
# toolchain is missing).
#
# Environment variables injected by BootOpenFlow's installer.rs:
#   BOOTFLOW_COMPONENT_ID — should be "hermes-self"
#   BOOTFLOW_STAGE        — "install" (only stage for v1.1)
#   BOOTFLOW_DATA_DIR     — base data dir (e.g. ~/Library/Application Support/BootOpenFlow)

set -u

# 0. Log the BOOTFLOW_* context (required by specs/hermes-self-install)
echo "[BOOTFLOW] component=${BOOTFLOW_COMPONENT_ID:-hermes-self}"
echo "[BOOTFLOW] stage=${BOOTFLOW_STAGE:-install}"
echo "[BOOTFLOW] data_dir=${BOOTFLOW_DATA_DIR:-<unset>}"

# 1. Detect upstream manifest (mutually exclusive — first match wins)
if [ -f package.json ]; then
  echo "[hermes-self] detected Node project (package.json)"
  if ! command -v npm >/dev/null 2>&1; then
    echo "[hermes-self] WARN: npm not in PATH; skipping (exit 0)"
    exit 0
  fi
  npm install --omit=dev
  echo "[hermes-self] npm install completed (exit=$?)"
  exit 0
fi

if [ -f pyproject.toml ]; then
  echo "[hermes-self] detected Python project (pyproject.toml)"
  if ! command -v uv >/dev/null 2>&1; then
    echo "[hermes-self] WARN: uv not in PATH; skipping (exit 0)"
    exit 0
  fi
  uv sync --frozen
  echo "[hermes-self] uv sync completed (exit=$?)"
  exit 0
fi

if [ -f Cargo.toml ]; then
  echo "[hermes-self] detected Rust project (Cargo.toml)"
  if ! command -v cargo >/dev/null 2>&1; then
    echo "[hermes-self] WARN: cargo not in PATH; skipping (exit 0)"
    exit 0
  fi
  cargo install --path . --locked
  echo "[hermes-self] cargo install completed (exit=$?)"
  exit 0
fi

# 2. No recognized manifest — placeholder branch
echo "no recognized manifest; hermes-self placeholder installed"
exit 0
