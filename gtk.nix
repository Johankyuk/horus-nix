{ config, pkgs, lib, ... }:
{
  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings."org/gnome/desktop/interface" = {
        icon-theme = "Papirus-Dark";
        cursor-theme = "Bibata-Modern-Classic";  # base; horus-theme rota a Bibata-Horus-*
        color-scheme = "prefer-dark";
      };
    }];
  };
}
