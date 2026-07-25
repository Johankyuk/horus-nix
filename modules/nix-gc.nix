{ lib, ... }:

{
  # Nix nunca sobrescribe: cada version de cada paquete es una ruta distinta en
  # /nix/store y sobrevive mientras alguna generacion la referencie. Sin esto,
  # el store crece de forma monotona con cada rebuild.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    # 30 dias es margen de sobra para revertir; lo que se borra es lo que ya
    # ninguna generacion viva referencia.
    options = "--delete-older-than 30d";
    randomizedDelaySec = "45min";
  };

  # Deduplica archivos identicos del store por hardlink. Programado (semanal)
  # en vez de auto-optimise-store, que paga el costo en cada build.
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Cada generacion mete su kernel+initrd en el ESP, que es de 1 GB. Sin tope,
  # el /boot se llena antes que el disco. mkDefault para no pisar el host.
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 20;
}
