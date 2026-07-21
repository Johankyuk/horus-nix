{ config, lib, pkgs, ... }:
{
  options.horus.apps.virt.enable =
    lib.mkEnableOption "virtualización (QEMU/KVM + virt-manager)" // { default = false; };
  config = lib.mkIf config.horus.apps.virt.enable {
    virtualisation.libvirtd.enable = true;
    # libvirt-guests solo imprime ruido en consola al apagar (no dejamos VMs corriendo)
    systemd.services.libvirt-guests.enable = lib.mkForce false;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
    users.users.${config.horus.user}.extraGroups = [ "libvirtd" ];
  };
}
