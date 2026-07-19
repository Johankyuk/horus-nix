{ config, lib, pkgs, ... }:
{
  options.horus.apps.toys.enable =
    lib.mkEnableOption "toys de terminal" // { default = true; };
  config = lib.mkIf config.horus.apps.toys.enable {
    environment.systemPackages = with pkgs; [ cava cmatrix tty-clock cbonsai lavat ];
  };
}
