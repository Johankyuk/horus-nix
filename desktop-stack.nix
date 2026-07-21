{ config, pkgs, lib, ... }:
let
  # Lanzadores de wizards Horus — FUENTE UNICA (antes tambien los generaba
  # horus-bootstrap; eliminado). Rutas absolutas al store: Noctalia corre como
  # servicio systemd con PATH curado y no resuelve nombres a secas.
  foot = "${pkgs.foot}/bin/foot";
  bash = "${pkgs.bash}/bin/bash";
  sw = "/run/current-system/sw/bin";
  mkWizard = id: en: es: cmd: pkgs.writeTextFile {
    name = "horus-${id}-desktop";
    destination = "/share/applications/horus-${id}.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=${en}
      Name[es]=${es}
      Comment=Horus wizard
      Comment[es]=Asistente Horus
      Exec=${cmd}
      Icon=preferences-system
      Terminal=false
      Categories=Settings;Utility;
    '';
  };
  # Wizards que terminan al instante: pausa para que foot no se cierre
  # Comillas DOBLES: las unicas que define la spec de Exec (las simples
  # dependen del parser de turno). Args extra van tras el nombre del bin.
  hold = cmd: "${foot} -e ${bash} -c \"${sw}/${cmd}; read -rsn1\"";
in
{
  environment.systemPackages = with pkgs; [
    (mkWizard "theme"     "Horus Theme"      "Horus Tema"        "${foot} -e ${sw}/horus-theme")
    (mkWizard "privacy"   "Horus Privacy"    "Horus Privacidad"  "${foot} -e ${sw}/horus-privacy")
    (mkWizard "language"  "Horus Language"   "Horus Idioma"      "${foot} -e ${sw}/horus-language")
    (mkWizard "power"     "Horus Power"      "Horus Energía"     (hold "horus-power --actual"))
    (mkWizard "kernel"    "Horus Kernel"     "Horus Kernel"      "${foot} -e ${sw}/horus-kernel")
    (mkWizard "status"    "Horus Status"     "Horus Estado"      (hold "horus-estado"))
    (mkWizard "update"    "Horus Update"     "Horus Update"      (hold "horus-update"))
    (mkWizard "mcshaders" "Horus MC Shaders" "Horus MC Shaders"  (hold "horus-mc-shaders"))

    # Iconos y cursor del stack (el overlay Horus-Folders lo genera horus-theme)
    pcmanfm-qt
    papirus-icon-theme
    bibata-cursors
    brightnessctl
    playerctl
  ];
}
