{ config, lib, pkgs, ... }:
{
  options.horus.apps.dev.enable =
    lib.mkEnableOption "desarrollo (VSCodium)" // { default = true; };
  config = lib.mkIf config.horus.apps.dev.enable {
    environment.systemPackages = [ pkgs.vscodium ];
  };
}
