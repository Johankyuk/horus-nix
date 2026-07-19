{ config, lib, pkgs, ... }:
{
  options.horus.apps.gaming.enable =
    lib.mkEnableOption "gaming (Steam)" // { default = true; };
  # Nota: si configuration.nix ya declara programs.steam.enable = true,
  # NixOS los fusiona sin conflicto (valores idénticos). El toggle vive aquí.
  config = lib.mkIf config.horus.apps.gaming.enable {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
    environment.systemPackages = with pkgs; [ mangohud protonplus heroic ];
  };
}
