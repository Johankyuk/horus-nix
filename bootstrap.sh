#!/usr/bin/env bash
# bootstrap.sh — Horus post-install para cualquier NixOS recién instalado.
# Uso: curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
set -euo pipefail

REPO_HTTPS="https://github.com/Johankyuk/horus-nix.git"
REPO_SSH="git@github.com:Johankyuk/horus-nix.git"
DEST="$HOME/horus-nix"
HOST="$(hostname)"
if [ "$HOST" = "nixos" ] || [ -z "$HOST" ]; then
  read -rp "Nombre para esta máquina (hostname/target): " HOST </dev/tty
fi
echo "[1/5] Clonando flake..."
[ -d "$DEST/.git" ] || nix-shell -p git --run "git clone $REPO_HTTPS $DEST"

echo "[2/5] Registrando esta máquina como host '$HOST'..."
if [ ! -d "$DEST/hosts/$HOST" ]; then
  echo "Kernel: 1) zen (desktop/gaming, default)  2) latest  3) lts  4) hardened"
  read -rp "Elige [1-4]: " K </dev/tty
  case "$K" in 2) KERNEL=latest;; 3) KERNEL=lts;; 4) KERNEL=hardened;; *) KERNEL=zen;; esac
  mkdir -p "$DEST/hosts/$HOST"
  cp /etc/nixos/hardware-configuration.nix "$DEST/hosts/$HOST/"
  cat > "$DEST/hosts/$HOST/default.nix" <<EOF
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];
  horus.kernel = "$KERNEL";
  # Overrides específicos de esta máquina van aquí (GPU, udev, hibernación...)
  networking.hostName = "$HOST";
}
EOF
  nix-shell -p git --run "git -C $DEST add hosts/$HOST"   # flakes solo ven tracked
fi

echo "[3/5] Rebuild (todo desde cache.nixos.org: kernel y drivers precompilados)..."
sudo nixos-rebuild switch --flake "$DEST#$HOST"

echo "[4/5] Cursores Bibata pre-generados (del repo)..."
if [ ! -d "$HOME/.icons/Bibata-Horus-morado" ]; then
  mkdir -p "$HOME/.icons"
  tar xzf "$DEST/cursors/bibata-horus-all.tar.gz" -C "$HOME/.icons" \
    || echo "[i] Tarball no encontrado; genera con: horus-cursor --all (~2h)"
fi

echo "[5/6] Contrasena del usuario..."
# mutableUsers=true: el usuario nace sin contrasena. Ponerla ahora (local, no
# viaja al repo). Si ya tiene una (reinstalacion sobre usuario existente), skip.
if ! sudo passwd -S "$USER" 2>/dev/null | grep -q " P "; then
  echo "El usuario '$USER' necesita contrasena. Definela:"
  passwd
else
  echo "  '$USER' ya tiene contrasena; no se toca."
fi

echo "[6/6] Remote a SSH..."
nix-shell -p git --run "git -C $DEST remote set-url origin $REPO_SSH"

echo "✓ terminado — reinicia para entrar a Horus"
