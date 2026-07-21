{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ./tuf.nix ];
  horus.kernel = "zen";
  horus.user = "kyu";

  # Usuario de ESTA maquina. Sin hashedPassword: se pone con `passwd` tras el
  # primer rebuild (mutableUsers=true lo conserva).
  users.users.${config.horus.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.bash;
  };

  # Bluetooth: bluez + bluetoothctl (Noctalia lo necesita); apagado al boot
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
