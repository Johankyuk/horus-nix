{ pkgs, ... }:

let
  clearFb = pkgs.writeShellScript "horus-clear-fb" ''
    # Solo al apagar/reiniciar de verdad. En un nixos-rebuild systemd tambien
    # detiene esta unidad, y sin este guard el chvt saca al usuario de su
    # sesion grafica hacia un tty vacio (parece que se apago, no se apago).
    estado=$(${pkgs.systemd}/bin/systemctl is-system-running 2>/dev/null || true)
    case "$estado" in
      stopping) ;;
      *) exit 0 ;;
    esac
    ${pkgs.kbd}/bin/chvt 6 || true
    ${pkgs.coreutils}/bin/printf '\033[2J\033[H\033[?25l' > /dev/tty6 || true
  '';
in
{
  # Limpia el framebuffer al apagar/reiniciar para que no quede congelado
  # el ultimo frame del compositor.
  systemd.services.horus-clear-fb = {
    description = "Limpia el framebuffer al apagar o reiniciar";
    before = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    # Un rebuild no debe tocarla: su unico trabajo es el ExecStop del apagado.
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${clearFb}";
      TimeoutStopSec = "5s";
    };
  };
}
