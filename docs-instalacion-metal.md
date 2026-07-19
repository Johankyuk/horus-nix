# Horus-Nix — instalación en hardware real

1. Bootear ISO de NixOS (minimal sirve). Particionar y montar en /mnt.
2. `nixos-generate-config --root /mnt`
3. `git clone https://github.com/Johankyuk/horus-nix.git /mnt/etc/horus-nix`
4. `cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/horus-nix/`
   `cd /mnt/etc/horus-nix && git add hardware-configuration.nix`
5. `nixos-install --flake /mnt/etc/horus-nix#horus-metal`
6. Reboot. Login kyu/horus (cambiar hash despues). El bootstrap clona
   Horus-Project, el seed ya pinto el primer arranque, horus-flatpak
   instala Sober y mcpelauncher.
