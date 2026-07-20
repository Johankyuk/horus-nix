{ ... }:
{
  imports = [ ./hardware-configuration.nix ./tuf.nix ];
  horus.kernel = "zen";
}
