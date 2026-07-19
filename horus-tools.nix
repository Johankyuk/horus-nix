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
    environment.HORUS_USER_HOME = "/home/kyu";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "exec horus-kbd-boot";
  };
  # Vigilante PRIME: en AC toda app nueva nace en la dGPU; en bateria, iGPU.
  # Guard interno: si no hay NVIDIA enumerada (dgpu_disable), se queda en iGPU.
  systemd.user.services.horus-gpu-watch = {
    description = "Vigilante de perfil GPU (PRIME por AC/bateria)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    path = [ horus-tools pkgs.coreutils pkgs.gnugrep pkgs.systemd pkgs.dbus ];
    serviceConfig = { Restart = "on-failure"; RestartSec = "5s"; };
    script = "exec horus-gpu-watch";
  };
}
