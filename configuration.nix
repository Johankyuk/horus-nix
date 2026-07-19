{ config, pkgs, lib, ... }:

{
  imports = [ ./noctalia.nix ./horus-tools.nix ./horus-bootstrap.nix
    ./sddm.nix
    ./desktop-stack.nix
    ./gtk.nix ];

  # Permitir paquetes no libres (driver NVIDIA)
  nixpkgs.config.allowUnfree = true;

  # ===================================================================
  # BOOT — equivalente a tu systemd-boot actual + kernel CachyOS
  # ===================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel CachyOS desde Chaotic-Nyx (mismos parches que usas hoy)
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # ===================================================================
  # IDENTIDAD DEL SISTEMA
  # ===================================================================
  networking.hostName = "horus";
  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "es_MX.UTF-8";

  # ===================================================================
  # GRÁFICOS — TUF A16: iGPU 780M + RTX 4050 en modo offload
  # Esto reemplaza tu configuración manual de PRIME y las 4 vars
  # de entorno que hoy inyectas por Flatpak override
  # ===================================================================
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;        # permite D3cold en batería
    powerManagement.finegrained = true;   # apaga la dGPU cuando no se usa
    open = true;                          # módulos open-kernel (Turing+)
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;    # te da el comando nvidia-offload
      amdgpuBusId = "PCI:101:0:0";        # 65:00.0 en hex → 101 en decimal
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ===================================================================
  # ESCRITORIO — Niri (módulo nativo en nixpkgs)
  # Noctalia no está empaquetado: se agrega quickshell y tu config
  # viaja como dotfile igual que hoy
  # ===================================================================
  programs.niri.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # ===================================================================
  # AUDIO
  # ===================================================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ===================================================================
  # PRIVACIDAD — esto es tu horus-privacy completo, declarativo
  # ===================================================================
  # DNS-over-TLS
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = "yes";
      FallbackDNS = [ "9.9.9.9" "149.112.112.112" ];
    };
  };
  networking.nameservers = [ "9.9.9.9#dns.quad9.net" ];

  # Firewall
  networking.firewall.enable = true;

  # MAC aleatoria por conexión (NetworkManager)
  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
  };

  # ===================================================================
  # HARDWARE ASUS — reemplaza tu horus-bat-limit y asusctl manual
  # ===================================================================
  services.asusd.enable = true;
  services.power-profiles-daemon.enable = true;

  # Límite de carga al 80% (lo que hoy haces con asusctl battery limit)
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

  # ===================================================================
  # GAMING — tu stack actual
  # ===================================================================
  programs.steam.enable = true;
  programs.gamescope.enable = true;

  services.flatpak.enable = true;   # apps (Sober, mcpelauncher) en metal.nix

  # ===================================================================
  # USUARIO
  # ===================================================================
  # Compat: foot.ini (y scripts del repo) esperan /bin/bash como en Arch
  environment.binsh = "${pkgs.bash}/bin/bash";
  system.activationScripts.binbash = ''
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';

  users.mutableUsers = false;

  users.users.kyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.bash;
    hashedPassword = "$6$K0g9Hj7.61uWCCgC$fc2OrvD3qqBt2BQwztiKCTnnschR0AuoIfCLv7wJRl7f0QoXdB2SWztK2hhBoCs6u9HKpJonXk.qrhYQZ0BQm1";
  };

  users.users.root.hashedPassword = "$6$K0g9Hj7.61uWCCgC$fc2OrvD3qqBt2BQwztiKCTnnschR0AuoIfCLv7wJRl7f0QoXdB2SWztK2hhBoCs6u9HKpJonXk.qrhYQZ0BQm1";

  # ===================================================================
  # PAQUETES — el equivalente a tus arrays de pacman en setup_master
  # ===================================================================
  environment.systemPackages = with pkgs; [
    # Terminal y CLI
    foot
    fastfetch
    git
    stow
    keyd

    # Escritorio
    pcmanfm-qt
    papirus-icon-theme

    # Gaming
    mangohud
    heroic
    protonup-qt

    # Utilidades
    python3
  ];

  # keyd como servicio (tu overload de Super → F13)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.leftmeta = "overload(meta, f13)";
    };
  };

  # ===================================================================
  # NUNCA CAMBIAR después de la primera instalación
  # ===================================================================
  # mkDefault: en metal lo pisa hardware-configuration.nix generado al instalar
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  system.stateVersion = "25.05";
}
