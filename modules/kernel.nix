{ config, lib, pkgs, ... }:
let
  cfg = config.horus.kernel;
  # Variantes disponibles — todas de nixpkgs
  kernels = {
    zen = pkgs.linuxPackages_zen;           # desktop responsivo, sin sched-ext
    latest = pkgs.linuxPackages_latest;     # mainline mas reciente en nixpkgs
    lts = pkgs.linuxPackages;               # LTS estable (default de NixOS)
    hardened = pkgs.linuxPackages_hardened; # foco en seguridad, menor rendimiento
  };
in {
  options.horus.kernel = lib.mkOption {
    type = lib.types.enum (builtins.attrNames kernels);
    default = "zen";
    description = "Variante de kernel del sistema";
  };
  config.boot.kernelPackages = kernels.${cfg};
}
