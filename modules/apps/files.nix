{ config, lib, pkgs, ... }:
{
  options.horus.apps.files.enable =
    lib.mkEnableOption "gestor de archivos (PCManFM-Qt + xarchiver)" // { default = true; };
  config = lib.mkIf config.horus.apps.files.enable {
    environment.systemPackages = with pkgs; [
      lxqt.pcmanfm-qt xarchiver ffmpegthumbnailer
      p7zip zip unzip rar
    ];
    services.gvfs.enable = true;      # montaje de USB/red desde el gestor
    services.udisks2.enable = true;
  };
}
