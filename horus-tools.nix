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
  environment.systemPackages = [ horus-tools ];
}
