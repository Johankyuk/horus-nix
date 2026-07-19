{ config, pkgs, lib, ... }:
{
  # RGB del teclado ITE5570 (LampArray) sin root — mismo rule que udev/ del repo
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*0B05:19B6*", MODE="0660", GROUP="input", TAG+="uaccess"
  '';

  # Flatpaks del stack (imperativos por naturaleza; se instalan al primer boot con red)
  systemd.user.services.horus-flatpak = {
    description = "Instala flatpaks del stack Horus";
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    script = ''
      flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || exit 0
      flatpak install -y --noninteractive --user flathub \
        org.vinegarhq.Sober io.mrarm.mcpelauncher || true
    '';
  };
  # Hibernación — swap por label (creado en el particionado del README)
  boot.resumeDevice = "/dev/disk/by-label/HORUS-SWAP";
  # kyu necesita el grupo input para hidraw (RGB ITE5570)
  users.users.kyu.extraGroups = [ "input" ];
  # Batería y perfiles de energía — Noctalia (UPower) y horus-power (PPD)
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
