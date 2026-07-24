{ pkgs, ... }:

let
  clearFb = pkgs.writeShellScript "horus-clear-fb" ''
    ${pkgs.kbd}/bin/chvt 6 || true
    ${pkgs.coreutils}/bin/printf '\033[2J\033[H\033[?25l' > /dev/tty6 || true
  '';
in
{
  # Limpia el framebuffer al apagar/reiniciar para que no quede congelado
  # el ultimo frame del compositor. Corre despues de display-manager al
  # detenerse (Before= en arranque = After= en apagado).
  systemd.services.horus-clear-fb = {
    description = "Limpia el framebuffer al apagar o reiniciar";
    before = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${clearFb}";
      TimeoutStopSec = "5s";
    };
  };
}
