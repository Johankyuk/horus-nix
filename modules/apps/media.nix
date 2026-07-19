{ config, lib, pkgs, ... }:
{
  options.horus.apps.media.enable =
    lib.mkEnableOption "media (OBS Studio)" // { default = true; };
  config = lib.mkIf config.horus.apps.media.enable {
    programs.obs-studio.enable = true;
    environment.systemPackages = with pkgs; [ vlc imv ];
  };
}
