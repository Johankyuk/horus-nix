{ config, lib, pkgs, ... }:
let
  cfg = config.horus.kernel;
  # Variantes disponibles — cachyos viene de Chaotic-Nyx, el resto de nixpkgs
  kernels = {
    cachyos = pkgs.linuxPackages_cachyos;   # gaming: sched-ext, BORE, parches CachyOS
    zen = pkgs.linuxPackages_zen;           # desktop responsivo, sin sched-ext
    latest = pkgs.linuxPackages_latest;     # mainline mas reciente en nixpkgs
    lts = pkgs.linuxPackages;               # LTS estable (default de NixOS)
    hardened = pkgs.linuxPackages_hardened; # foco en seguridad, menor rendimiento
  };
in {
  options.horus.kernel = lib.mkOption {
    type = lib.types.enum (builtins.attrNames kernels);
    default = "cachyos";
    description = "Variante de kernel del sistema";
  };
  config.boot.kernelPackages = kernels.${cfg};
}
