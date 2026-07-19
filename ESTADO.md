# Estado del porteo Horus → NixOS (17 jul, cierre ~22:00)

## Hecho (esta sesión)
- Migrado a Nix NATIVO (pacman `nix` 2.34.8 + nix-daemon + sandbox real).
  nix-portable ABANDONADO y borrado: sin sandbox, `/homeless-shelter`
  rompía un derivation por intento (rustc, cargo, cargo-auditable...).
  Ese dir vivía dentro del namespace efímero: `sudo rm` era inútil.
- /nix en subvolumen btrfs propio (@nix), fuera de snapshots.
- Daemon con TMPDIR=/var/tmp (disco real, no el tmpfs de 7.5G).
- /etc/nix/nix.conf: trusted-users, sandbox=true, substituters chaotic-nyx.
  El paquete nix 2.34.8 ya NO crea el grupo `nix-users` (acceso por socket).
- Build: `nix build .#nixosConfigurations.horus.config.system.build.vm -L`
  (sin flags, sin TMPDIR: todo vive en la config)
- VM validada: arranca, SDDM autentica, sesión Niri, kernel cachyos 7.1.3.
- horus-bootstrap.nix: systemd user service que replica bootstrap.sh
  (pasos 1-3; el paso 4 `exec setup_master.sh` es pacman puro y su
  equivalente ya está en configuration.nix). Clona repo, escribe
  ~/.config/horus/repo, `cp -rn config/. ~/.config/`.
  VALIDADO: 8 kdl + foot.ini + settings.json desplegados, config.kdl 344 b.

## Decisiones tomadas (no re-litigar)
- home-manager DESCARTADO: horus-theme hace `open(path,"w")` (línea 109) y
  horus-cursor `sed -i` sobre config.kdl → contra symlinks read-only al
  store, revientan. Solo 7 archivos son estáticos (animation/autostart/
  display/input/keybinds/misc/rules.kdl); el resto lo rota el motor de
  temas. Los dotfiles siguen mutables por diseño, desplegados por copia.
- Stow es legado: no aparece en setup_master.sh, el despliegue es `cp`.
- Niri crea config.kdl vacío si no lo halla y bloquea al `cp -n`
  → el módulo lo borra antes de copiar. Hay carrera Niri vs bootstrap;
  si vuelve a salir 0 bytes, ordenar con Before= en el unit.

## Límite de la VM (no es bug del sistema)
Niri levanta pero NO renderiza: `software EGL renderers are skipped`.
virtio-gpu-gl no sirve: el qemu del store de Nix no ve los Mesa de
CachyOS (`eglGetDisplay failed`). Haría falta nixGL o el qemu de pacman.
=> Lo visual (Noctalia, wallpaper, cursores, iconos, RGB) SOLO se valida
en físico. La VM ya dio todo lo que podía dar.

## Siguiente sesión — orden sugerido
1. THEMING (a ciegas en VM, solo se verifica que no muera):
   enganchar horus-theme en la activación. Hoy fastfetch sale con logo y
   colores de NixOS. OJO: horus-theme lee fuentes desde ~/Horus-Project en
   runtime (líneas 20-22, 314, 353, 471) → el repo clonado es requisito.
2. NOCTALIA: noctalia.nix tiene el hash v4.7.7 clavado, pero nunca se vio
   corriendo. Verificar que quickshell + settings.json aterricen.
3. hardware-configuration.nix REAL: el `fileSystems."/"` de hoy es relleno
   de VM (/dev/disk/by-label/nixos, ext4). Sin esto no hay físico.

## Bloqueos para físico (resolver ANTES de tocar nada)
- BitLocker: extraer la clave de recuperación PRIMERO. Tocar ESP o layout
  puede disparar la petición en el arranque de Windows. 130 GB en juego.
- Sin partición libre: habría que reducir /home (204G) o / (112G), btrfs vivo.
- ESP de 2G compartido con CachyOS + Windows: ver quién pisa a quién con
  los hooks de kyu-os-title (/boot/loader/entries/*.conf).
- password "horus" en claro + mutableUsers=false → cambiar a hashedPassword
  (mkpasswd -m yescrypt) antes de cualquier instalación real.

## Comandos base
cd ~/horus-nix && nix build .#nixosConfigurations.horus.config.system.build.vm -L
cd ~/horus-vm && QEMU_OPTS="-m 8192 -smp 6" ~/horus-nix/result/bin/run-horus-vm
# VM: Ctrl+Alt+1 = VGA (SDDM/Niri), Ctrl+Alt+3 = serial (consola de texto)
# login kyu / horus
