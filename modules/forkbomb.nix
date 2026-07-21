{ config, lib, pkgs, ... }:
{
  # ── Anti-forkbomb ──
  # Techo de procesos por usuario (cgroups v2): toda sesion, grafica o TTY,
  # vive bajo user-<uid>.slice. Drop-in estilo upstream: systemd aplica
  # user-.slice.d a TODOS los slices de usuario. Root y servicios de sistema
  # no se tocan (los builds de nix corren en system.slice).
  systemd.units."user-.slice.d/50-horus-tasksmax.conf".text = ''
    [Slice]
    TasksMax=4096
  '';

  # Respaldo a nivel kernel (rlimit via PAM). Aplica en el siguiente login.
  security.pam.loginLimits = [
    { domain = "@users"; item = "nproc"; type = "soft"; value = "4096"; }
    { domain = "@users"; item = "nproc"; type = "hard"; value = "4096"; }
  ];

  # El taunt: hook de prompt solo-builtins (funciona con el slice saturado).
  programs.bash.interactiveShellInit = ''
    __horus_forkguard() {
      local cg=/sys/fs/cgroup/user.slice/user-$UID.slice max cur
      [ -r "$cg/pids.max" ] || return 0
      read -r max < "$cg/pids.max" 2>/dev/null || return 0
      [ "$max" = "max" ] && return 0
      read -r cur < "$cg/pids.current" 2>/dev/null || return 0
      if (( cur * 10 < max * 9 )); then __HORUS_FG_LAST=0; return 0; fi
      (( EPOCHSECONDS - ''${__HORUS_FG_LAST:-0} < 30 )) && return 0
      __HORUS_FG_LAST=$EPOCHSECONDS
      printf '\n\033[1;35m✋ nice try, rookie.\033[0m  %s/%s procesos — forkbomb contenida por Horus\n' "$cur" "$max"
      printf '\033[2m(los forks nuevos fallan; espera a que mueran, o kill -9 -1 limpia todo cerrando la sesion)\033[0m\n'
    }
    PROMPT_COMMAND="__horus_forkguard''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  '';
}
