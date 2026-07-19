{
  description = "Horus — NixOS declarativo (equivalente a setup_master.sh, pero como sistema operativo)";

  inputs = {
    # Rama rolling de nixpkgs — lo más cercano a Arch en frescura
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Chaotic-Nyx: kernel CachyOS, mesa-git, paquetes bleeding-edge
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }: {
    nixosConfigurations.horus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        chaotic.nixosModules.default   # habilita linuxPackages_cachyos y el cache binario
        ./configuration.nix
      ];
    };
  };
}
