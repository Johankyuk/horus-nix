{ config, pkgs, lib, ... }:
{
  # ── ASUS TUF A16: Ryzen 8040 + Radeon 780M + RTX 4050 ──
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.asusd.enable = true;
  systemd.services.battery-limit = {
    description = "Límite de carga al 80%";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
        echo 80 > "$f"
      done
    '';
  };

  # RGB del teclado ITE5570 (LampArray) sin root
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*0B05:19B6*", MODE="0660", GROUP="input", TAG+="uaccess"
  '';
  users.users.kyu.extraGroups = [ "input" ];

  # Hibernación (swap con label del particionado de esta máquina)
  boot.resumeDevice = "/dev/disk/by-label/HORUS-SWAP";

  # GPP0 (root port dGPU) despierta la máquina al hibernar
  systemd.services.acpi-wakeup-fix = {
    description = "Deshabilita wakeup ACPI de GPP0 (aborta hibernacion)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = "grep -q \"^GPP0.*enabled\" /proc/acpi/wakeup && echo GPP0 > /proc/acpi/wakeup || true";
  };

  # Watchdog de hardware AMD: no lo usamos y su "watchdog did not stop!"
  # ensucia la consola al apagar (post-Plymouth, imposible de tapar)
  boot.blacklistedKernelModules = [ "sp5100_tco" ];
}
