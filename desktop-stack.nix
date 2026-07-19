{ config, pkgs, lib, ... }:
let
  # Lanzadores de wizards Horus. En CachyOS los genera setup_master.sh;
  # aqui son declarativos. Exec por nombre: la sesion NixOS resuelve
  # /run/current-system/sw/bin en PATH.
  mkWizard = id: nombre: cmd: pkgs.writeTextFile {
    name = "horus-${id}-desktop";
    destination = "/share/applications/horus-${id}.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=${nombre}
      Comment=Asistente Horus
      Exec=${cmd}
      Icon=preferences-system
      Terminal=false
      Categories=Settings;Utility;
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    (mkWizard "tema" "Horus Tema" "foot -e horus-theme")
    (mkWizard "privacidad" "Horus Privacidad" "foot -e horus-privacy")
    # horus-estado termina al instante: pausa para que foot no se cierre
    (mkWizard "estado" "Horus Estado" "foot -e bash -c 'horus-estado; read -rsn1'")

    # Iconos y cursor del stack (el overlay Horus-Folders lo genera horus-theme)
    pcmanfm-qt
    papirus-icon-theme
    bibata-cursors
    brightnessctl
    playerctl
  ];
}
