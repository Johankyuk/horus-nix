{ config, lib, pkgs, ... }:
{
  # ── Guard anti "rm -rf /" ──
  # coreutils ya bloquea rm -rf / (preserve-root), pero NO cubre:
  #   rm -rf /*            (el glob expande antes de que rm vea la raiz)
  #   --no-preserve-root   (bypass explicito)
  # Guard SOLO en shells interactivas: scripts y automatizacion intactos.
  programs.bash.interactiveShellInit = ''
    __horus_rmguard() {
      local rec=0 a
      for a in "$@"; do
        case "$a" in
          --no-preserve-root) return 0 ;;
          --recursive|-*[rR]*) rec=1 ;;
        esac
      done
      [ "$rec" = 1 ] || return 1
      for a in "$@"; do
        case "''${a%/}" in
          # "" cubre la raiz: ''${a%/} de "/" da cadena vacia
          ""|/|/nix|/etc|/home|/usr|/var|/boot|/root|/bin|/lib|/srv|/opt) return 0 ;;
        esac
      done
      return 1
    }
    __horus_rmtaunt() {
      printf '\n\033[1;35m✋ nice try, rookie.\033[0m  borrado de sistema contenido por Horus\n'
      printf '\033[2m(si de verdad sabes lo que haces: command %s ...)\033[0m\n' "$1"
      return 1
    }
    rm() {
      __horus_rmguard "$@" && { __horus_rmtaunt rm; return 1; }
      command rm "$@"
    }
    sudo() {
      [ "''${1:-}" = rm ] && __horus_rmguard "''${@:2}" && { __horus_rmtaunt "sudo rm"; return 1; }
      command sudo "$@"
    }
  '';
}
