{ config, lib, pkgs, inputs, ... }:
{
  options.horus.apps.zen.enable =
    lib.mkEnableOption "Zen Browser (flake comunitario)" // { default = true; };
  config = lib.mkIf config.horus.apps.zen.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
