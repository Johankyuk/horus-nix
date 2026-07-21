# Horus

**A better Noctalia for laptops.**

[Español](#español) · [English](#english)

---

<a name="español"></a>
## Español

Flake de NixOS que convierte cualquier instalación limpia en un escritorio Niri + Noctalia completo, temado y consciente del hardware: gestión dual-GPU, hibernación funcional, límite de carga de batería, RGB del teclado antes del login, y un motor de temas OKLCH que recolorea todo el sistema —compositor, shell, terminal, SDDM, iconos, cursor, wallpaper y teclado— con un solo comando.

Todo se construye desde `nixpkgs` (rama `nixos-unstable`) y `cache.nixos.org`: el kernel y los drivers bajan precompilados, sin repos de terceros ni compilaciones largas.

### Instalación

Horus se instala sobre **cualquier NixOS ya arrancado**, sin importar cómo llegaste ahí. Dos rutas según de dónde partas:

#### Ruta A — ISO minimal (recomendada)

La vía limpia: no instalas un escritorio que vas a desechar.

1. Arranca la [ISO minimal de NixOS](https://nixos.org/download/) y particiona el disco.

   > **Hibernación (paso pre-install, obligatorio si la quieres):** crea aquí una partición de swap con label `HORUS-SWAP` y tamaño ≥ tu RAM. Tiene que hacerse al particionar; el flake se engancha a ese label por `boot.resumeDevice`, pero **no crea la partición por ti**. Sin este paso no hay hibernación, y añadirla después implica reparticionar un disco en uso.

2. Genera la config base e instala un sistema mínimo (`nixos-generate-config`, `nixos-install`). Con esto ya tienes un NixOS que arranca.
3. En el primer boot, corre el bootstrap (abajo).

#### Ruta B — Sobre un NixOS con escritorio (Calamares/GNOME)

Más fácil de arrancar, pero instalas un escritorio intermedio que Horus reemplaza.

1. Instala NixOS con la ISO gráfica normal (Calamares te deja un GNOME funcional).
2. En el primer boot, corre el bootstrap. La generación Horus reemplaza el escritorio anterior; GNOME deja de estar en la generación activa y el recolector de basura lo borra después.

#### El bootstrap (ambas rutas)

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

Reinicia. Listo.

El bootstrap registra tu máquina como un host propio del flake (`hosts/<hostname>/`) copiando su `hardware-configuration.nix`, te pregunta qué kernel quieres, hace el rebuild (todo desde `cache.nixos.org`), extrae los cursores Bibata pre-generados del repo, te pide definir la contraseña de tu usuario, y cambia el remote a SSH.

### Usuario y contraseña

Horus usa `mutableUsers = true`: cada máquina define su propio usuario en `hosts/<hostname>/default.nix`, y **la contraseña se pone localmente con `passwd`** — nunca vive en el repo. El bootstrap te la pide en la instalación. Si reinstalas sobre un usuario que ya tiene contraseña, no la toca.

Así puedes instalar Horus en tu máquina con tu propio usuario sin editar el código ni heredar credenciales ajenas.

### Tiempo de instalación

Dominado por la descarga del closure del sistema (hasta ~17 GiB con todos los módulos habilitados —gaming, virt, office—; menos si recortas los que no uses), no por compilación:

| Conexión | Aprox. |
|---|---|
| 50 Mbps | ~45 min |
| 100 Mbps | ~20 min |
| 200+ Mbps | ~10 min |

Más ~2-5 min de bootstrap (dotfiles + cursores) y ~5-10 min de flatpaks en segundo plano al primer boot (no bloquean el escritorio).

### Qué incluye

- **Niri + Noctalia** (v4, pineado) sobre Wayland, SDDM con tema sugar-dark recoloreable
- **`horus-theme`**: 11 temas OKLCH; un comando repinta todo en vivo
- **Herramientas en el launcher**: shortcuts ejecutables desde el lanzador de Noctalia — `Horus Theme`, `Horus Privacy`, `Horus Status`, `Horus Update`, `Horus Language`, `Horus Power`, `Horus MC Shaders`, `Horus Kernel`
- **Dual GPU (laptops AMD+NVIDIA)**: PRIME offload declarativo, `horus-gpu-watch` cambia iGPU/dGPU, perfil de energía y envelope de CPU según AC/batería
- **Laptop-first**: hibernación validada, límite de carga al 80%, botón de power → lockscreen, cerrar tapa sin suspender, RGB pre-SDDM, fan curves por perfil y fuente, toggle de rendimiento (fans + CPU al máximo por Noctalia)
- **Privacidad declarativa**: DNS-over-TLS, firewall, aleatorización de MAC (`horus-privacy` para toggles en runtime)
- **Gaming**: Steam, gamescope, MangoHud temado, `horus-fsr` y config declarativa de Sober (Roblox: Vulkan, FPS sin tope)
- **Kernel seleccionable**: `horus.kernel` = zen / latest / lts / hardened; el bootstrap pregunta al instalar. `horus-kernel` cambia la variante después desde el launcher (**inestable**: edita el host y reconstruye, aún en pruebas)
- **`horus-update`**: bumpea inputs del flake, reconstruye, commitea el lock y actualiza flatpaks en un comando. Update atómico: si el bump rompe el build, revierte el lock solo y deja el sistema intacto
- **Boot y apagado silenciosos** con branding Horus y generaciones limitadas

### Estructura

| Ruta | Rol |
|---|---|
| `configuration.nix` | Sistema Horus completo, genérico para cualquier máquina |
| `hosts/<name>/` | Un directorio por máquina: hardware-config + usuario + overrides (referencia: `hosts/horus`, ASUS TUF A16) |
| `modules/` | Módulos opcionales (kernel seleccionable, sets de apps) |
| `horus-bin/` | Herramientas (`horus-theme`, `horus-privacy`, `horus-kernel`…) |
| `cursors/` | Cursores Bibata pre-generados (11 temas) |
| `bootstrap.sh` | Post-install en un comando |

El contenido (wallpapers, temas, branding) vive en [Horus-Project](https://github.com/Johankyuk/Horus-Project).

---

<a name="english"></a>
## English

A NixOS flake that turns any clean install into a complete, themed, hardware-aware Niri + Noctalia desktop: dual-GPU management, working hibernation, battery charge limit, keyboard RGB before login, and an OKLCH theme engine that recolors the whole system —compositor, shell, terminal, SDDM, icons, cursor, wallpaper and keyboard— with a single command.

Everything builds from `nixpkgs` (`nixos-unstable`) and `cache.nixos.org`: the kernel and drivers arrive precompiled, no third-party repos or long compiles.

### Installation

Horus installs on top of **any already-booted NixOS**, no matter how you got there. Two routes depending on your starting point:

#### Route A — Minimal ISO (recommended)

The clean way: you don't install a desktop you're going to throw away.

1. Boot the [NixOS minimal ISO](https://nixos.org/download/) and partition the disk.

   > **Hibernation (pre-install step, required if you want it):** create a swap partition labeled `HORUS-SWAP`, size ≥ your RAM, here. It must be done at partition time; the flake hooks onto that label via `boot.resumeDevice`, but **does not create the partition for you**. Without this step there's no hibernation, and adding it later means repartitioning a disk in use.

2. Generate the base config and install a minimal system (`nixos-generate-config`, `nixos-install`). You now have a booting NixOS.
3. On first boot, run the bootstrap (below).

#### Route B — On a NixOS with a desktop (Calamares/GNOME)

Easier to start, but you install an intermediate desktop that Horus replaces.

1. Install NixOS with the regular graphical ISO (Calamares leaves you a working GNOME).
2. On first boot, run the bootstrap. The Horus generation replaces the previous desktop; GNOME leaves the active generation and the garbage collector removes it later.

#### The bootstrap (both routes)

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

Reboot. Done.

The bootstrap registers your machine as its own flake host (`hosts/<hostname>/`) by copying its `hardware-configuration.nix`, asks which kernel you want, runs the rebuild (all from `cache.nixos.org`), extracts the pre-generated Bibata cursors from the repo, prompts you to set your user's password, and switches the remote to SSH.

### User and password

Horus uses `mutableUsers = true`: each machine defines its own user in `hosts/<hostname>/default.nix`, and **the password is set locally with `passwd`** — it never lives in the repo. The bootstrap asks for it at install time. If you reinstall over a user that already has a password, it's left untouched.

This means you can install Horus on your machine with your own user without editing the code or inheriting anyone else's credentials.

### Install time

Dominated by downloading the system closure (up to ~17 GiB with all modules enabled —gaming, virt, office—; less if you trim the ones you don't use), not by compilation:

| Connection | Approx. |
|---|---|
| 50 Mbps | ~45 min |
| 100 Mbps | ~20 min |
| 200+ Mbps | ~10 min |

Plus ~2-5 min of bootstrap (dotfiles + cursors) and ~5-10 min of flatpaks in the background on first boot (they don't block the desktop).

### What's included

- **Niri + Noctalia** (v4, pinned) on Wayland, SDDM with a recolorable sugar-dark theme
- **`horus-theme`**: 11 OKLCH themes; one command repaints everything live
- **Launcher tools**: shortcuts runnable from the Noctalia launcher — `Horus Theme`, `Horus Privacy`, `Horus Status`, `Horus Update`, `Horus Language`, `Horus Power`, `Horus MC Shaders`, `Horus Kernel`
- **Dual GPU (AMD+NVIDIA laptops)**: declarative PRIME offload, `horus-gpu-watch` switches iGPU/dGPU, power profile and CPU envelope on AC/battery
- **Laptop-first**: validated hibernation, 80% charge limit, power button → lockscreen, lid-close without suspend, pre-SDDM RGB, per-profile-and-power-source fan curves, performance toggle (fans + CPU maxed via Noctalia)
- **Declarative privacy**: DNS-over-TLS, firewall, MAC randomization (`horus-privacy` for runtime toggles)
- **Gaming**: Steam, gamescope, themed MangoHud, `horus-fsr` and declarative Sober config (Roblox: Vulkan, uncapped FPS)
- **Selectable kernel**: `horus.kernel` = zen / latest / lts / hardened; the bootstrap asks on install. `horus-kernel` switches the variant later from the launcher (**unstable**: edits the host and rebuilds, still in testing)
- **`horus-update`**: bumps flake inputs, rebuilds, commits the lock and updates flatpaks in one command. Atomic update: if the bump breaks the build, it reverts the lock itself and leaves the system intact
- **Silent boot & shutdown** with Horus branding and limited generations

### Layout

| Path | Role |
|---|---|
| `configuration.nix` | Full Horus system, generic for any machine |
| `hosts/<name>/` | One directory per machine: hardware-config + user + overrides (reference: `hosts/horus`, ASUS TUF A16) |
| `modules/` | Optional modules (selectable kernel, app sets) |
| `horus-bin/` | Tooling (`horus-theme`, `horus-privacy`, `horus-kernel`…) |
| `cursors/` | Pre-generated Bibata cursors (11 themes) |
| `bootstrap.sh` | One-command post-install |

Content (wallpapers, themes, branding) lives in [Horus-Project](https://github.com/Johankyuk/Horus-Project).
