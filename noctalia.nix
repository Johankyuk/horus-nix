{ config, pkgs, lib, ... }:
let
  # ===================================================================
  # PAQUETE: Noctalia v4 desde TU fork, congelada para siempre
  # Esto reemplaza: IgnorePkg + assets vendorizados + hooks de pacman
  # ===================================================================
  noctalia-src = pkgs.fetchFromGitHub {
    owner = "Johankyuk";
    repo = "noctalia";
    rev = "309f2d44315ed62098cfc2d344ef0fe6491199f1";   # rama horus (v4.7.7 + parches propios)
    hash = "sha256-ldGmqAfTe5asDuM4d5goqEZiImiAJvrfhWYqaizyZFc=";
  };
  noctalia-pkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "noctalia-shell";
    version = "4.7.7-horus";
    src = noctalia-src;
    # Los parches (perfiles en español, fix del icono) viven en la rama horus
    # del fork, no aquí: en git son explícitos y no se saltan en silencio.
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
    "d ${config.horus.home}/.config 0755 ${config.horus.user} users -"
    "d ${config.horus.home}/.config/quickshell 0755 ${config.horus.user} users -"
    "L+ ${config.horus.home}/.config/quickshell/noctalia-shell - ${config.horus.user} users - /etc/xdg/quickshell/noctalia-shell"
  ];

  # Noctalia como servicio de usuario: revive solo si muere (a diferencia de
  # spawn-at-startup de Niri, que solo lanza una vez). ExecStart usa el wrapper
  # noctalia-run (qs del fork + config congelada del store).
  systemd.user.services.noctalia = {
    description = "Noctalia shell (barra + launcher)";
    # PATH del servicio: Noctalia lanza subprocesos con sh (launcher, widgets).
    # Sin esto arranca degradado (barra sí, launcher/disk no).
    path = with pkgs; [ bash coreutils util-linux procps networkmanager bluez python3 fontconfig imagemagick ]
      # Perfil del sistema completo: el launcher antepone customLaunchPrefix
      # (horus-gpu) a todo spawn y necesita resolverlo, igual que foot.
      ++ [ "/run/wrappers" "/run/current-system/sw" ];
      # /run/wrappers PRIMERO: ahi vive el sudo setuid de NixOS. Sin el,
      # los wizards lanzados desde el launcher resuelven el sudo sin setuid
      # de sw/bin y mueren ("debe ser propiedad del uid 0").
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
