{ config, pkgs, lib, ... }:
let
  # Seed: snapshot pineado del repo para el PRIMER boot (sin red, sin race).
  # El bootstrap actualiza a main real despues. Re-pinear: re-correr el
  # bloque generador en el host.
  horus-seed-src = pkgs.fetchFromGitHub {
    owner = "Johankyuk";
    repo = "Horus-Project";
    rev = "2ba844f790d4f455bf0edb2969b0351dc1500a1e";
    hash = "sha256-tj/ktwOcblsResgtV3AgmPM/EBOSNDQxKcEGlp+eM7s=";
  };
in
{
  # Corre en el boot del sistema, ANTES de SDDM: cuando Niri arranca,
  # config.kdl ya existe con el spawn de Noctalia incluido.
  systemd.services.horus-seed = {
    description = "Seed inicial de config Horus antes de la sesion";
    wantedBy = [ "display-manager.service" ];
    before = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /home/kyu/.config
      for d in niri noctalia foot; do
        if [ ! -e "/home/kyu/.config/$d" ] && [ -e "${horus-seed-src}/config/$d" ]; then
          cp -r --no-preserve=mode,ownership "${horus-seed-src}/config/$d" "/home/kyu/.config/$d"
        fi
      done
      chown -R kyu:users /home/kyu/.config
    '';
  };

  systemd.user.services.horus-bootstrap = {
    description = "Clona Horus-Project y despliega dotfiles";
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.git pkgs.coreutils pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      REPO_URL="https://github.com/Johankyuk/Horus-Project.git"
      DEST="$HOME/Horus-Project"
      REF="main"

      if [ -d "$DEST/.git" ]; then
        git -C "$DEST" fetch --depth 1 origin "$REF" || exit 0
        git -C "$DEST" reset --hard "origin/$REF"
      else
        git clone --depth 1 --branch "$REF" "$REPO_URL" "$DEST" || exit 0
      fi

      mkdir -p "$HOME/.config/horus"
      printf '%s\n' "$DEST" > "$HOME/.config/horus/repo"

      # Anti-race: si el config.kdl no es el del repo (no tiene includes
      # modulares), es el autogenerado de Niri -> fuera
      NIRI_CFG="$HOME/.config/niri/config.kdl"
      if [ -f "$NIRI_CFG" ] && ! grep -q 'include "./cfg' "$NIRI_CFG"; then
        rm -f "$NIRI_CFG"
      fi

      # Symlink de quickshell (redundante con tmpfiles, idempotente)
      mkdir -p "$HOME/.config/quickshell"
      ln -sfn /etc/xdg/quickshell/noctalia-shell "$HOME/.config/quickshell/noctalia-shell"

      # Copia solo lo ausente: no pisa lo que horus-theme rota
      cp -rn "$DEST/config/." "$HOME/.config/" 2>/dev/null || true

      # fastfetch: su config vive en branding/, no en config/
      mkdir -p "$HOME/.config/fastfetch"
      [ -f "$HOME/.config/fastfetch/config.jsonc" ] || cp "$DEST/branding/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
      [ -f "$HOME/.config/fastfetch/logo.txt" ] || cp "$DEST/branding/horus-ascii.txt" "$HOME/.config/fastfetch/logo.txt"
    '';
  };
}
