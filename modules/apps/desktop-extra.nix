{ config, lib, pkgs, ... }:
{
  options.horus.apps.desktopExtra.enable =
    lib.mkEnableOption "theming, portales, fuentes, utilidades de escritorio" // { default = true; };
  config = lib.mkIf config.horus.apps.desktopExtra.enable {
    environment.systemPackages = with pkgs; [
      qt6Packages.qt6ct papirus-icon-theme bibata-cursors catppuccin-gtk
      imagemagick xorg.xcursorgen xcur2png       # generacion cursor Bibata-Horus
      libnotify wlsunset wob wl-mirror
    ];
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    fonts.packages = with pkgs; [
      nerd-fonts.meslo-lg noto-fonts-color-emoji noto-fonts-cjk-sans
    ];
  };
}
