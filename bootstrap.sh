#!/usr/bin/env bash
# bootstrap.sh — Horus post-install para NixOS recién instalado.
# Uso: curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
set -euo pipefail

REPO_HTTPS="https://github.com/Johankyuk/horus-nix.git"
REPO_SSH="git@github.com:Johankyuk/horus-nix.git"
DEST="$HOME/horus-nix"

echo "[1/4] Clonando flake..."
if [ ! -d "$DEST/.git" ]; then
  nix-shell -p git --run "git clone $REPO_HTTPS $DEST"
fi

echo "[2/4] Usando hardware-configuration.nix de ESTA máquina..."
if [ -f /etc/nixos/hardware-configuration.nix ]; then
  cp /etc/nixos/hardware-configuration.nix "$DEST/hardware-configuration.nix"
fi

echo "[3/4] Rebuild al flake Horus..."
sudo nixos-rebuild switch --flake "$DEST#horus-metal"

echo "[4/4] Remote a SSH (push funcional una vez cargada tu llave)..."
nix-shell -p git --run "git -C $DEST remote set-url origin $REPO_SSH"

echo "✓ terminado — reinicia para entrar a Horus (Niri + Noctalia + SDDM temado)"
