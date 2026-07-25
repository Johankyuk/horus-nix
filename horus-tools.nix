{ config, pkgs, ... }:

let
  # ===================================================================
  # PAQUETE: herramientas Horus (horus-theme, horus-privacy, etc.)
  # Fuente: carpeta local ./horus-bin — sin dependencia de git
  # ===================================================================
  horus-tools = pkgs.stdenvNoCC.mkDerivation {
    pname = "horus-tools";
    version = "1.0";
    src = ./horus-bin;

    # bash y python disponibles para que patchShebangs los resuelva
    buildInputs = [ pkgs.bash pkgs.python3 ];

    installPhase = ''
      mkdir -p $out/bin
      cp * $out/bin/
      chmod +x $out/bin/*
    '';
    # patchShebangs corre solo en la fase fixup:
    # reescribe #!/bin/bash → /nix/store/...-bash/bin/bash
  };

in
{
  environment.systemPackages = [ horus-tools pkgs.pciutils pkgs.psmisc ];

  # RGB del teclado con el color del tema ANTES de SDDM.
  # Espera al ITE5570 (hasta 30s, patron cold-boot EC) y pinta una vez;
  # en sesion, horus-kbd-fx toma el control.
  systemd.services.horus-kbd-boot = {
    description = "RGB del teclado antes del login";
    wantedBy = [ "display-manager.service" ];
    before = [ "display-manager.service" ];
    path = [ horus-tools pkgs.coreutils pkgs.gnugrep ];
    environment.HORUS_USER_HOME = config.horus.home;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "exec horus-kbd-boot";
  };
  # Vigilante PRIME: en AC toda app nueva nace en la dGPU; en bateria, iGPU.
  # Guard interno: si no hay NVIDIA enumerada (dgpu_disable), se queda en iGPU.
  # Respaldo automatico: SOLO empuja commits ya hechos. No commitea nada por
  # su cuenta (auto-commitear a media edicion ensucia el historial), pero un
  # commit local sin subir es riesgo puro, y eso si lo resuelve.
  systemd.user.services.horus-sync = {
    description = "Empuja commits pendientes de los repos Horus a GitHub";
    path = [ horus-tools pkgs.git pkgs.openssh pkgs.coreutils pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${horus-tools}/bin/horus-sync --push";
    };
  };
  systemd.user.timers.horus-sync = {
    description = "Respaldo diario de los repos Horus";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "10min";
      OnUnitActiveSec = "1d";
      Persistent = true;
      RandomizedDelaySec = "20min";
    };
  };

  # Shell propia (quickshell sobre niri). Como servicio y no en autostart.kdl
  # porque el OSD de Noctalia ya esta apagado: si esta muere, Kyu se queda sin
  # indicador de volumen ni brillo hasta reiniciar la sesion.
  systemd.user.services.horus-shell = {
    description = "Horus shell (OSD y modulos propios)";
    # qs vive en el perfil del sistema; el PATH de un servicio no es el del shell.
    path = with pkgs; [ bash coreutils fontconfig ]
      ++ [ "/run/wrappers" "/run/current-system/sw" ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${horus-tools}/bin/horus-shell";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.user.services.horus-gpu-watch = {
    description = "Vigilante de perfil GPU (PRIME por AC/bateria)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    # asusctl (fan curves) y sudo con setuid viven fuera del store: sin estos
    # dos, command -v asusctl falla y el bloque de curvas se salta en silencio.
    path = [ horus-tools pkgs.coreutils pkgs.gnugrep pkgs.systemd pkgs.dbus pkgs.power-profiles-daemon ]
      ++ [ "/run/wrappers" "/run/current-system/sw" ];
    serviceConfig = { Restart = "on-failure"; RestartSec = "5s"; };
    script = "exec horus-gpu-watch";
  };
}
