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

      # fastfetch: su config vive en branding/, no en config/
      mkdir -p "$HOME/.config/fastfetch"
      [ -f "$HOME/.config/fastfetch/config.jsonc" ] || cp "$DEST/branding/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
      [ -f "$HOME/.config/fastfetch/logo.txt" ] || cp "$DEST/branding/horus-ascii.txt" "$HOME/.config/fastfetch/logo.txt"
      # Prompt minimalista (marca idempotente, igual que sec_generables en Arch)
      if ! grep -q '# horus-prompt' "$HOME/.bashrc" 2>/dev/null; then
        printf '\n# horus-prompt\nPS1=""\n' >> "$HOME/.bashrc"
      fi
      # Lanzadores .desktop de los wizards (100% generados: se sobreescriben)
      APPS="$HOME/.local/share/applications"
      mkdir -p "$APPS"
      SW=/run/current-system/sw/bin
      gen_desktop() {  # $1=id $2=nombre $3=exec
        printf '[Desktop Entry]\nType=Application\nName=%s\nComment=Asistente Horus\nExec=%s\nIcon=preferences-system\nTerminal=false\nCategories=Settings;Utility;\n' \
          "$2" "$3" > "$APPS/horus-$1.desktop"
      }
      [ -x "$SW/horus-theme" ]   && gen_desktop tema       "Horus Tema"       "foot -e $SW/horus-theme"
      [ -x "$SW/horus-privacy" ] && gen_desktop privacidad "Horus Privacidad" "foot -e $SW/horus-privacy"
      [ -x "$SW/horus-estado" ]  && gen_desktop estado     "Horus Estado"     "foot -e bash -c \"$SW/horus-estado; read -rsn1\""
      [ -x "$SW/horus-update" ]  && gen_desktop update     "Horus Update"     "foot -e bash -c \"$SW/horus-update; read -rsn1\""
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
