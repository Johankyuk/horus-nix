{ config, pkgs, lib, ... }:
let
  horus-src = pkgs.fetchFromGitHub {
    owner = "Johankyuk";
    repo = "Horus-Project";
    rev = "2ba844f790d4f455bf0edb2969b0351dc1500a1e";
    hash = "sha256-tj/ktwOcblsResgtV3AgmPM/EBOSNDQxKcEGlp+eM7s=";
  };
  sddm-sugar-dark-horus = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-sugar-dark-horus";
    version = "horus";
    src = horus-src;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sugar-dark-horus
      cp -r sugar-dark-horus/. $out/share/sddm/themes/sugar-dark-horus/
      # Estatico en NixOS: el repo trae .jpg; el .png lo genera horus-theme en CachyOS
      substituteInPlace $out/share/sddm/themes/sugar-dark-horus/theme.conf \
        --replace 'Background="Background.png"' 'Background="Background.jpg"'
      # El metadata declara Qt5 -> SDDM busca un greeter Qt5 inexistente
      sed -i 's/^QtVersion=.*/QtVersion=6/' \
        $out/share/sddm/themes/sugar-dark-horus/metadata.desktop
      grep -q '^QtVersion=6' $out/share/sddm/themes/sugar-dark-horus/metadata.desktop \
        || echo 'QtVersion=6' >> $out/share/sddm/themes/sugar-dark-horus/metadata.desktop
      # Port Qt5 -> Qt6: QtGraphicalEffects vive ahora en Qt5Compat
      find $out/share/sddm/themes/sugar-dark-horus -name '*.qml' \
        -exec sed -i 's/^import QtGraphicalEffects.*/import Qt5Compat.GraphicalEffects/' {} +
      # Theming dinamico: conf y fondo viven en /var/lib/horus-sddm (mutable)
      T=$out/share/sddm/themes/sugar-dark-horus
      cp $T/theme.conf $T/theme.conf.default
      sed -i 's/Background="Background.jpg"/Background="Background.png"/' $T/theme.conf.default
      cp $T/Background.jpg $T/Background.default
      rm -f $T/theme.conf $T/Background.png
      ln -s /var/lib/horus-sddm/theme.conf $T/theme.conf
      ln -s /var/lib/horus-sddm/Background.png $T/Background.png
    '';
  };
in
{
  services.displayManager.sddm = {
    theme = "sugar-dark-horus";
    # Runtime QML del tema en Qt6: GraphicalEffects viene de qt5compat
    extraPackages = [ pkgs.kdePackages.qt5compat ];
  };
  environment.systemPackages = [ sddm-sugar-dark-horus ];

  # Seed inicial de /var/lib/horus-sddm (solo si no existe)
  system.activationScripts.horus-sddm-seed = ''
    mkdir -p /var/lib/horus-sddm
    [ -f /var/lib/horus-sddm/theme.conf ] || cp ${sddm-sugar-dark-horus}/share/sddm/themes/sugar-dark-horus/theme.conf.default /var/lib/horus-sddm/theme.conf
    [ -f /var/lib/horus-sddm/Background.png ] || cp ${sddm-sugar-dark-horus}/share/sddm/themes/sugar-dark-horus/Background.default /var/lib/horus-sddm/Background.png
    chmod 755 /var/lib/horus-sddm
    chmod 644 /var/lib/horus-sddm/*
  '';

  # sudoers NOPASSWD: horus-theme llama sudo horus-sddm-apply
  security.sudo.extraRules = [{
    users = [ "kyu" ];
    commands = [
      { command = "/run/current-system/sw/bin/horus-sddm-apply"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/horus-sddm-apply *"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/horus-cpu-cap *"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
