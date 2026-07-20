#!/usr/bin/env bash
# bootstrap.sh — Horus post-install para cualquier NixOS recién instalado.
# Uso: curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
set -euo pipefail

REPO_HTTPS="https://github.com/Johankyuk/horus-nix.git"
REPO_SSH="git@github.com:Johankyuk/horus-nix.git"
DEST="$HOME/horus-nix"
HOST="$(hostname)"
CACHE_OPTS=(--option extra-substituters "https://chaotic-nyx.cachix.org"
            --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=")

echo "[1/5] Clonando flake..."
[ -d "$DEST/.git" ] || nix-shell -p git --run "git clone $REPO_HTTPS $DEST"

echo "[2/5] Registrando esta máquina como host '$HOST'..."
if [ ! -d "$DEST/hosts/$HOST" ]; then
  mkdir -p "$DEST/hosts/$HOST"
  cp /etc/nixos/hardware-configuration.nix "$DEST/hosts/$HOST/"
  cat > "$DEST/hosts/$HOST/default.nix" <<EOF
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];
  # Overrides específicos de esta máquina van aquí (GPU, udev, hibernación...)
  networking.hostName = "$HOST";
}
EOF
  nix-shell -p git --run "git -C $DEST add hosts/$HOST"   # flakes solo ven tracked
fi

echo "[3/5] Rebuild (cache Chaotic activo: kernel CachyOS precompilado)..."
sudo nixos-rebuild switch --flake "$DEST#$HOST" "${CACHE_OPTS[@]}"

echo "[4/5] Cursores Bibata pre-generados (release asset)..."
if [ ! -d "$HOME/.icons/Bibata-Horus-morado" ]; then
  mkdir -p "$HOME/.icons"
  curl -sL "https://github.com/Johankyuk/horus-nix/releases/download/cursors-v1/bibata-horus-all.tar.gz" \
    | tar xz -C "$HOME/.icons" \
    || echo "[i] Asset de cursores no disponible; genera con: horus-cursor --all (~2h)"
fi

echo "[5/5] Remote a SSH..."
nix-shell -p git --run "git -C $DEST remote set-url origin $REPO_SSH"

echo "✓ terminado — reinicia para entrar a Horus"
