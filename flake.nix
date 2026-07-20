{
  description = "Horus — NixOS declarativo (equivalente a setup_master.sh, pero como sistema operativo)";

  inputs = {
    # Rama rolling de nixpkgs — lo más cercano a Arch en frescura
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Zen Browser — no esta en nixpkgs (branding), flake comunitario estandar
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      mkSystem = extraModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./configuration.nix ] ++ extraModules;
      };
      hostNames = builtins.attrNames
        (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./hosts));
    in {
      nixosConfigurations =
        # target generico para la VM de pruebas (sin hardware)
        { horus-vm = mkSystem [ ]; }
        # cada carpeta en hosts/ es un target real (nombre = hostname)
        // nixpkgs.lib.genAttrs hostNames (name: mkSystem [ (./hosts + "/${name}") ]);
    };
}
