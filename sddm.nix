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
}
