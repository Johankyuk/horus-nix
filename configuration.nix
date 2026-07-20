{ config, pkgs, lib, ... }:

{
  imports = [ ./noctalia.nix ./horus-tools.nix ./horus-bootstrap.nix
    ./sddm.nix
    ./desktop-stack.nix
    ./gtk.nix
    ./modules/apps ];

  # Permitir paquetes no libres (driver NVIDIA)
  nixpkgs.config.allowUnfree = true;

  # ===================================================================
  # BOOT — equivalente a tu systemd-boot actual + kernel CachyOS
  # ===================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];
  system.nixos.distroName = "Horus";
  # Silenciar mensajes de systemd al apagar/reiniciar (equivalente al quiet del boot)
  systemd.settings.Manager.ShowStatus = "no";

  # Boton de encendido: tap = nada (Niri lo maneja), long-press = apagar
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Kernel CachyOS desde Chaotic-Nyx (mismos parches que usas hoy)
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # ===================================================================
  # IDENTIDAD DEL SISTEMA
  # ===================================================================
  networking.hostName = "horus";
  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "es_MX.UTF-8";

  # Teclado latam: SDDM/Weston lo hereda de aqui; consola aparte
  services.xserver.xkb.layout = "latam";
  console.keyMap = "la-latin1";

  # Fuentes: foot pide "monospace"; sin esto fontconfig no resuelve
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    dejavu_fonts
    noto-fonts
  ];

  # ===================================================================
  # GRÁFICOS — TUF A16: iGPU 780M + RTX 4050 en modo offload
  # Esto reemplaza tu configuración manual de PRIME y las 4 vars
  # de entorno que hoy inyectas por Flatpak override
  # ===================================================================
  hardware.graphics.enable = true;

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
    hashedPassword = "$6$6/kkeSZCW6DEn.qw$PlK5PWqW/XndDhTw8F2d3mlT1rhTimcrgk8RevTHzgHUxtU/H612vwiS.fJQme48OlvBvzQAxRoqhYm7XA2PZ.";
  };

  users.users.root.hashedPassword = "$6$6/kkeSZCW6DEn.qw$PlK5PWqW/XndDhTw8F2d3mlT1rhTimcrgk8RevTHzgHUxtU/H612vwiS.fJQme48OlvBvzQAxRoqhYm7XA2PZ.";

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
    bibata-cursors  # base para horus-cursor
    imagemagick     # recoloreo de cursores
    gtk3  # gtk-update-icon-cache para horus-theme
    glib  # gsettings para horus-theme
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


  # Flatpaks del stack (imperativos por naturaleza; primer boot con red)
  systemd.user.services.horus-flatpak = {
    description = "Instala flatpaks del stack Horus";
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig = { Type = "oneshot"; RemainAfterExit = true; Restart = "on-failure"; RestartSec = "10s"; };
    script = ''
      flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || exit 0
      flatpak install -y --noninteractive --user flathub \
        org.vinegarhq.Sober io.mrarm.mcpelauncher || true
    '';
  };
  services.upower.enable = true;

  system.stateVersion = "25.05";
}
