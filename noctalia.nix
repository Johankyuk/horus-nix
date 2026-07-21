{ config, pkgs, lib, ... }:
let
  # ===================================================================
  # PAQUETE: Noctalia v4 desde TU fork, congelada para siempre
  # Esto reemplaza: IgnorePkg + assets vendorizados + hooks de pacman
  # ===================================================================
  noctalia-src = pkgs.fetchFromGitHub {
    owner = "Johankyuk";
    repo = "noctalia";
    rev = "3abfa1fc09b62dc4cdeeb7b787886f075696f0b7";   # commit exacto de v4.7.7 — inmutable
    hash = "sha256-QszLpoDPD7JEv8B/w1U2u1ksBw/CYBDmwUTLhJrekF0=";
  };
  noctalia-pkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "noctalia-shell";
    version = "4.7.7-horus";
    src = noctalia-src;
    # Toasts de perfil de energía en español + fix del icono (antes:
    # horus-noctalia-es + hook de pacman en Arch; aquí horneado en el paquete).
    # Icono: upstream deriva la clave del NOMBRE del perfil; con nombres
    # traducidos la clave no existe y cae a la calavera -> getIcon() siempre.
    postPatch = ''
      F=Services/Power/PowerProfileService.qml
      if [ -f "$F" ]; then
        substituteInPlace "$F" \
          --replace-warn 'profileName.toLowerCase().replace(" ", "")' 'root.getIcon()' \
          --replace-warn 'return "Performance";' 'return "Rendimiento";' \
          --replace-warn 'return "Balanced";' 'return "Equilibrado";' \
          --replace-warn 'return "Power saver";' 'return "Ahorro de energía";'
      fi
    '';
    # Sin compilación: solo copiar la config QML al store
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
  # ===================================================================
  # PAQUETE: noctalia-qs — quickshell del fork (freeze v0.0.12)
  # El quickshell genérico de nixpkgs NO trae los tipos del fork
  # (PwAudioSpectrum, etc.) y Noctalia colapsa en cascada sin ellos.
  # Reutilizamos la receta de nixpkgs cambiando solo el src.
  # ===================================================================
  noctalia-qs = pkgs.quickshell.overrideAttrs (old: {
    pname = "noctalia-qs";
    version = "0.0.12-horus";
    src = pkgs.fetchFromGitHub {
      owner = "Johankyuk";
      repo = "noctalia-qs";
      rev = "e7224b756dcd10eec040df818a4c7a0fda5d6eff";  # tag v0.0.12 — inmutable
      hash = "sha256-79JP2QTdvp1jg7HGxAW+xzhzhLnlKUi8yGXq9nDCeH0=";  # freeze v0.0.12
    };
  });
  # Lanzador: el qs del fork apuntando a la config congelada en el store
  noctalia-run = pkgs.writeShellScriptBin "noctalia" ''
    exec ${noctalia-qs}/bin/qs -p ${noctalia-pkg}
  '';
in
{
  environment.etc."xdg/quickshell/noctalia-shell".source = noctalia-pkg;

  # Symlink creado en el boot del SISTEMA, antes de SDDM. Los tmpfiles de
  # usuario y el bootstrap corren en paralelo a la sesion -> race con qs.
  # A nivel sistema es deterministico: no hay sesion todavia.
  systemd.tmpfiles.rules = [
    "d /home/kyu/.config 0755 kyu users -"
    "d /home/kyu/.config/quickshell 0755 kyu users -"
    "L+ /home/kyu/.config/quickshell/noctalia-shell - kyu users - /etc/xdg/quickshell/noctalia-shell"
  ];

  # Noctalia como servicio de usuario: revive solo si muere (a diferencia de
  # spawn-at-startup de Niri, que solo lanza una vez). ExecStart usa el wrapper
  # noctalia-run (qs del fork + config congelada del store).
  systemd.user.services.noctalia = {
    description = "Noctalia shell (barra + launcher)";
    # PATH del servicio: Noctalia lanza subprocesos con sh (launcher, widgets).
    # Sin esto arranca degradado (barra sí, launcher/disk no).
    path = with pkgs; [ bash coreutils util-linux procps networkmanager bluez python3 fontconfig imagemagick cliphist wl-clipboard ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${noctalia-qs}/bin/qs -c noctalia-shell";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  environment.systemPackages = [
    noctalia-qs
    noctalia-run
    pkgs.xwayland-satellite
    pkgs.cliphist
    pkgs.wl-clipboard
  ];
}
