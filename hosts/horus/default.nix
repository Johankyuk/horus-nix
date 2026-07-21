{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ./tuf.nix ];
  horus.kernel = "zen";

  # Usuario de ESTA maquina. Sin hashedPassword: se pone con `passwd` tras el
  # primer rebuild (mutableUsers=true lo conserva).
  users.users.kyu = {
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
