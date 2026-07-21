{ config, pkgs, lib, ... }:
let
  # Seed: snapshot pineado del repo para el PRIMER boot (sin red, sin race).
  # El bootstrap actualiza a main real despues. Re-pinear: re-correr el
  # bloque generador en el host.
  horus-seed-src = pkgs.fetchFromGitHub {
    owner = "Johankyuk";
    repo = "Horus-Project";
    rev = "5cb532f48f79e9103276ce673f33947172a9f6e0";
    hash = "sha256-qRKOwO99Ak+SIYzwVcXy7dKraGjX10HbZaz5I6saJHA=";
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
      mkdir -p ${config.horus.home}/.config
      for d in niri noctalia foot; do
        if [ ! -e "${config.horus.home}/.config/$d" ] && [ -e "${horus-seed-src}/config/$d" ]; then
          cp -r --no-preserve=mode,ownership "${horus-seed-src}/config/$d" "${config.horus.home}/.config/$d"
        fi
      done
      chown -R ${config.horus.user}:users ${config.horus.home}/.config
    '';
  };

  systemd.user.services.horus-bootstrap = {
    description = "Clona Horus-Project y despliega dotfiles";
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.git pkgs.coreutils pkgs.gnugrep pkgs.python3 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
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

      # Portabilidad del wallpaper: reescribir la ruta al $HOME real de quien instala.
      NOCTA="$HOME/.config/noctalia/settings.json"
      if [ -f "$NOCTA" ]; then
        ${pkgs.python3}/bin/python3 -c "import sys,json; f=sys.argv[1]; wd=sys.argv[2]; d=json.load(open(f)); d.setdefault('wallpaper',{}); d['wallpaper']['directory']=wd; json.dump(d,open(f,'w'),indent=2)" "$NOCTA" "$HOME/Horus-Project/Wallpapers" 2>/dev/null || true
      fi

      # fastfetch: su config vive en branding/, no en config/
      mkdir -p "$HOME/.config/fastfetch"
      [ -f "$HOME/.config/fastfetch/config.jsonc" ] || cp "$DEST/branding/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
      [ -f "$HOME/.config/fastfetch/logo.txt" ] || cp "$DEST/branding/horus-ascii.txt" "$HOME/.config/fastfetch/logo.txt"
      # Prompt minimalista (marca idempotente, igual que sec_generables en Arch)
      if ! grep -q '# horus-prompt' "$HOME/.bashrc" 2>/dev/null; then
        printf '\n# horus-prompt\nPS1=""\n' >> "$HOME/.bashrc"
      fi
      # Lanzadores de wizards: declarativos en desktop-stack.nix (fuente unica).
      # Limpieza de los que generaba este bootstrap en versiones previas:
      rm -f "$HOME/.local/share/applications/horus-"{theme,privacy,status,update,language,power,mcshaders,kernel}.desktop
      APPS="$HOME/.local/share/applications"
      mkdir -p "$APPS"
      # Ocultar .desktop de sistema en el launcher (override usuario, reversible)
      for _h in avahi-discover bssh bvnc qv4l2 qvidcap foot footclient foot-server \
                qt6ct xarchiver btop micro vim nvim htop \
                org.pulseaudio.pavucontrol nixos-manual rog-control-center; do
        printf '[Desktop Entry]\nType=Application\nName=%s\nNoDisplay=true\nHidden=true\nX-Kyu-Launcher-Hide=1\n' \
          "$_h" > "$APPS/$_h.desktop"
      done
    '';
  };
}
