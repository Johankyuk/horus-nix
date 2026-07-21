{ config, lib, ... }:
{
  # Usuario principal del host: se declara en hosts/<host>/default.nix.
  # Todo lo que antes hardcodeaba /home/kyu deriva de aqui.
  options.horus.user = lib.mkOption {
    type = lib.types.str;
    description = "Usuario principal del host.";
  };
  options.horus.home = lib.mkOption {
    type = lib.types.str;
    default = "/home/${config.horus.user}";
    description = "Home del usuario principal (derivado de horus.user).";
  };
}
