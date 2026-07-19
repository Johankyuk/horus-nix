# Horus — NixOS

> **A better Noctalia — for laptops.** Now declarative.

**English** | [Español](#espanol)

This is the NixOS twin of [Horus-Project](https://github.com/Johankyuk/Horus-Project). Everything `setup_master.sh` does imperatively on CachyOS, this flake declares: same Niri + Noctalia v4 desktop, same purple theme, same tools — reproducible with one build.

It's a personal setup, kept public as a reference.

## Targets

| Target | Use |
|---|---|
| `horus` | QEMU VM for testing |
| `horus-metal` | Real hardware (ASUS TUF A16: NVIDIA PRIME, RGB, battery limit) |

## Try it in a VM

```bash
./vm-rebuild.sh   # builds the system + regenerates the host-side runner
./vm-run.sh       # boots it (virtio-gpu with GL)
```

Login: `kyu` / `horus`.

## Install on metal

Full flow in [docs-instalacion-metal.md](docs-instalacion-metal.md): boot the NixOS ISO, generate `hardware-configuration.nix`, clone this repo, `nixos-install --flake .#horus-metal`.

## Layout

- `configuration.nix` — base system: boot, Niri, keyd, NVIDIA, firewall, privacy.
- `noctalia.nix` — Noctalia **frozen at v4.7.7**, built from the pinned fork (`Johankyuk/noctalia-qs`). The declarative version of the Arch `IgnorePkg` freeze.
- `horus-tools.nix` — the `horus-*` scripts packaged into the store.
- `horus-bootstrap.nix` — pinned seed for the first offline boot, then clones Horus-Project and deploys dotfiles, prompt, and wizard launchers. Horus-Project stays the single source of truth for configs.
- `sddm.nix`, `desktop-stack.nix`, `gtk.nix` — greeter theme, session plumbing, icons/cursor.
- `metal.nix` — hardware-only extras (udev RGB, Flatpaks: Sober, mcpelauncher).
- `modules/apps/` — optional app sets behind toggles.

## App toggles

Every app category is a module with an option, on by default:

```nix
horus.apps.office.enable = false;   # skip OnlyOffice
horus.apps.gaming.enable = false;   # skip Steam/MangoHud/Heroic
```

Categories: `dev`, `office`, `virt`, `gaming`, `media`, `files`, `zen`, `toys`, `desktopExtra`. A future install wizard only needs to generate a file of toggles — nothing else.

---

<a name="espanol"></a>

# Horus — NixOS (Español)

> **Un Noctalia mejor — para laptops.** Ahora declarativo.

El gemelo NixOS de [Horus-Project](https://github.com/Johankyuk/Horus-Project). Todo lo que `setup_master.sh` hace imperativamente en CachyOS, este flake lo declara: mismo escritorio Niri + Noctalia v4, mismo tema morado, mismas herramientas — reproducible con un build.

Es un setup personal, público como referencia.

## Targets

| Target | Uso |
|---|---|
| `horus` | VM QEMU para pruebas |
| `horus-metal` | Hardware real (ASUS TUF A16: NVIDIA PRIME, RGB, límite de batería) |

## Probar en VM

```bash
./vm-rebuild.sh   # compila el sistema + regenera el runner del host
./vm-run.sh       # arranca (virtio-gpu con GL)
```

Login: `kyu` / `horus`.

## Instalar en metal

Flujo completo en [docs-instalacion-metal.md](docs-instalacion-metal.md): ISO de NixOS, generar `hardware-configuration.nix`, clonar este repo, `nixos-install --flake .#horus-metal`.

## Estructura

- `configuration.nix` — sistema base: boot, Niri, keyd, NVIDIA, firewall, privacidad.
- `noctalia.nix` — Noctalia **congelado en v4.7.7**, compilado desde el fork pineado (`Johankyuk/noctalia-qs`). La versión declarativa del freeze por `IgnorePkg` de Arch.
- `horus-tools.nix` — los scripts `horus-*` empaquetados al store.
- `horus-bootstrap.nix` — seed pineado para el primer boot sin red; después clona Horus-Project y despliega dotfiles, prompt y lanzadores de wizards. Horus-Project sigue siendo la única fuente de verdad de las configs.
- `sddm.nix`, `desktop-stack.nix`, `gtk.nix` — tema del greeter, plomería de sesión, iconos/cursor.
- `metal.nix` — extras solo-hardware (udev RGB, Flatpaks: Sober, mcpelauncher).
- `modules/apps/` — sets de apps opcionales tras toggles.

## Toggles de apps

Cada categoría es un módulo con opción, encendida por default:

```nix
horus.apps.office.enable = false;   # sin OnlyOffice
horus.apps.gaming.enable = false;   # sin Steam/MangoHud/Heroic
```

Categorías: `dev`, `office`, `virt`, `gaming`, `media`, `files`, `zen`, `toys`, `desktopExtra`. Un futuro wizard de instalación solo genera un archivo de toggles — nada más.

---

## Instalación en metal (disco completo, TUF A16) / Bare-metal install

> ES only — runbook operativo. English readers: this is the operator's install runbook.

### 0. Antes de apagar CachyOS
- [ ] Respaldo de minecraftWorlds (mcpelauncher) copiado a USB/nube
- [ ] Secure Boot DESACTIVADO en BIOS (sbctl viene después)
- [ ] ISO gráfica de NixOS (GNOME) en USB — solo es el entorno vivo, el sistema final sale del flake

### 1. Bootear ISO → conectar wifi (GUI) → terminal → `sudo -i`

### 2. Particionado (BORRA TODO EL DISCO)
```bash
DISK=/dev/nvme0n1   # verificar con: lsblk -d
lsblk "$DISK" && read -rp "¿Borrar $DISK completo? (escribe SI): " ok && [ "$ok" = "SI" ]
RAM=$(free -g | awk '/Mem/{print $2+1}'); SWAP=$((RAM+4))
wipefs -af "$DISK"
parted -s "$DISK" mklabel gpt \
  mkpart ESP fat32 1MiB 1025MiB set 1 esp on \
  mkpart swap linux-swap 1025MiB "$((1025+SWAP*1024))MiB" \
  mkpart root btrfs "$((1025+SWAP*1024))MiB" 100%
mkfs.fat -F32 -n HORUS-ESP "${DISK}p1"
mkswap -L HORUS-SWAP "${DISK}p2" && swapon "${DISK}p2"
mkfs.btrfs -f -L HORUS-ROOT "${DISK}p3"
mount "${DISK}p3" /mnt
btrfs subvolume create /mnt/@ && btrfs subvolume create /mnt/@home
umount /mnt
mount -o subvol=@,compress=zstd:3,noatime "${DISK}p3" /mnt
mkdir -p /mnt/home /mnt/boot
mount -o subvol=@home,compress=zstd:3,noatime "${DISK}p3" /mnt/home
mount "${DISK}p1" /mnt/boot
echo "✓ terminado"
```

### 3. Config + instalación
```bash
nixos-generate-config --root /mnt
nix-shell -p git --run "git clone https://github.com/Johankyuk/horus-nix.git /mnt/etc/horus-nix"
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/horus-nix/
cd /mnt/etc/horus-nix && nix-shell -p git --run "git add hardware-configuration.nix"
nixos-install --flake /mnt/etc/horus-nix#horus-metal
echo "✓ terminado — reboot"
```
**Crítico:** el `git add` del hardware-configuration es obligatorio — los flakes ignoran archivos sin trackear y el install fallaría con el placeholder.

### 4. Post-boot (primer arranque)
- Login `kyu` con la contraseña real (hash ya en el repo)
- El bootstrap clona Horus-Project; `horus-flatpak` instala Sober y mcpelauncher (necesita red)
- Verificar: script de verificación de VM + `swapon --show` + `cat /sys/power/resume` no vacío
- Restaurar mundo: abrir mcpelauncher una vez, luego
  `tar -xzf mc-worlds-respaldo-*.tar.gz -C ~/.var/app/io.mrarm.mcpelauncher/data/mcpelauncher/games/com.mojang/minecraftWorlds/`
- Mover repo: `sudo mv /etc/horus-nix ~/horus-nix && sudo chown -R kyu:users ~/horus-nix`

### Pendientes post-metal
Secure Boot (sbctl), GTA V Steam + BattlEye block.
