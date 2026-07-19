{ config, lib, pkgs, ... }:
{
  options.horus.apps.virt.enable =
    lib.mkEnableOption "virtualización (QEMU/KVM + virt-manager)" // { default = true; };
  config = lib.mkIf config.horus.apps.virt.enable {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
    users.users.kyu.extraGroups = [ "libvirtd" ];
  };
}
