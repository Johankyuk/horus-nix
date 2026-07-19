{ config, lib, pkgs, ... }:
{
  options.horus.apps.office.enable =
    lib.mkEnableOption "ofimática (OnlyOffice)" // { default = true; };
  config = lib.mkIf config.horus.apps.office.enable {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
