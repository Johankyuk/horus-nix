# Horus

**A better Noctalia for laptops.**

[Español](#español) · [English](#english)

---

<a name="español"></a>
## Español

Flake de NixOS que convierte cualquier instalación limpia en un escritorio Niri + Noctalia completo, temado y consciente del hardware: gestión dual-GPU, hibernación funcional, límite de carga de batería, RGB del teclado antes del login, y un motor de temas OKLCH que recolorea todo el sistema —compositor, shell, terminal, SDDM, iconos, cursor, wallpaper y teclado— con un solo comando.

### Instalar en tu máquina

1. Instala NixOS con cualquier ISO oficial (la minimal es la vía rápida: ~5 min y no instalas un desktop que vas a desechar). Si quieres hibernación, crea el swap con label `HORUS-SWAP`.
2. En el primer boot:

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

3. Reinicia. Listo.

El bootstrap registra tu máquina como un host propio del flake (`hosts/<hostname>/`) con su `hardware-configuration.nix`, hace el rebuild con el cache binario de Chaotic-Nyx (kernel CachyOS precompilado — minutos, no horas), y extrae los cursores pre-generados del repo. Overrides específicos de esa máquina (GPU, udev, hibernación) van después en `hosts/<hostname>/default.nix`.

Supuesto del flake: el usuario es `kyu` (`mutableUsers = false`); cualquier usuario creado por el instalador deja de existir tras el switch.

### Probar sin instalar (VM)

```bash
cd vm && ./vm-rebuild.sh && ./vm-run.sh
```

### Qué incluye

- **Niri + Noctalia** (v4, pineado) sobre Wayland, SDDM con tema sugar-dark recoloreable
- **`horus-theme`**: 11 temas rotados en OKLCH; un comando repinta todo en vivo
- **Dual GPU (laptops AMD+NVIDIA)**: PRIME offload declarativo, `horus-gpu-watch` cambia iGPU/dGPU, perfil de energía y envelope del CPU según AC/batería
- **Laptop-first**: hibernación validada, carga limitada al 80%, botón de encendido → lockscreen, RGB pre-SDDM, toggle rendimiento (fans + CPU al máximo, solo AC)
- **Privacidad declarativa**: DNS-over-TLS, firewall, MAC aleatoria (`horus-privacy` para toggles runtime)
- **Gaming**: Steam, gamescope, MangoHud temado, `horus-fsr`
- **Boot y apagado silenciosos** con branding Horus y generaciones limitadas

### Estructura

| Ruta | Rol |
|---|---|
| `configuration.nix` | Sistema Horus completo, genérico para cualquier máquina |
| `hosts/<nombre>/` | Un directorio por máquina: hardware-config + overrides (referencia: `hosts/horus`, ASUS TUF A16) |
| `horus-bin/` | Tooling (`horus-theme`, `horus-privacy`, `horus-gpu`…) |
| `cursors/` | Cursores Bibata pre-generados (11 temas) |
| `vm/` | Pruebas en QEMU sin tocar hardware |
| `bootstrap.sh` | Post-install de un comando |

El contenido (wallpapers, temas, branding) vive en [Horus-Project](https://github.com/Johankyuk/Horus-Project).

---

<a name="english"></a>
## English

NixOS flake that turns any clean install into a complete, themed, hardware-aware Niri + Noctalia desktop: dual-GPU management, working hibernation, battery charge limit, keyboard RGB before login, and an OKLCH theme engine that recolors the whole system —compositor, shell, terminal, SDDM, icons, cursor, wallpaper and keyboard— with a single command.

### Install on your machine

1. Install NixOS from any official ISO (minimal is the fast path: ~5 min, no throwaway desktop). For hibernation, create swap labeled `HORUS-SWAP`.
2. On first boot:

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

3. Reboot. Done.

The bootstrap registers your machine as its own flake host (`hosts/<hostname>/`) with its `hardware-configuration.nix`, rebuilds using the Chaotic-Nyx binary cache (precompiled CachyOS kernel — minutes, not hours), and extracts pre-generated cursors from the repo. Machine-specific overrides (GPU, udev, hibernation) go in `hosts/<hostname>/default.nix` afterwards.

Flake assumption: the user is `kyu` (`mutableUsers = false`); any installer-created user ceases to exist after the switch.

### Try without installing (VM)

```bash
cd vm && ./vm-rebuild.sh && ./vm-run.sh
```

### What's included

- **Niri + Noctalia** (v4, pinned) on Wayland, SDDM with a recolorable sugar-dark theme
- **`horus-theme`**: 11 OKLCH-rotated themes; one command repaints everything live
- **Dual GPU (AMD+NVIDIA laptops)**: declarative PRIME offload, `horus-gpu-watch` switches iGPU/dGPU, power profile and CPU envelope on AC/battery
- **Laptop-first**: validated hibernation, 80% charge limit, power button → lockscreen, pre-SDDM RGB, performance toggle (fans + CPU maxed, AC only)
- **Declarative privacy**: DNS-over-TLS, firewall, MAC randomization (`horus-privacy` for runtime toggles)
- **Gaming**: Steam, gamescope, themed MangoHud, `horus-fsr`
- **Silent boot & shutdown** with Horus branding and limited generations

### Layout

| Path | Role |
|---|---|
| `configuration.nix` | Full Horus system, generic for any machine |
| `hosts/<name>/` | One directory per machine: hardware-config + overrides (reference: `hosts/horus`, ASUS TUF A16) |
| `horus-bin/` | Tooling (`horus-theme`, `horus-privacy`, `horus-gpu`…) |
| `cursors/` | Pre-generated Bibata cursors (11 themes) |
| `vm/` | QEMU testing without touching hardware |
| `bootstrap.sh` | One-command post-install |

Content (wallpapers, themes, branding) lives in [Horus-Project](https://github.com/Johankyuk/Horus-Project).
