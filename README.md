# Horus

**A better Noctalia for laptops.**

[Español](#español) · [English](#english)

---

<a name="español"></a>
## Español

Flake de NixOS que convierte una instalación limpia en un escritorio Niri + Noctalia completo, temado y consciente del hardware: gestión dual-GPU (offload iGPU/dGPU con apagado por firmware), hibernación funcional, límite de carga de batería, RGB del teclado antes del login, y un motor de temas OKLCH que recolorea todo el sistema —compositor, shell, terminal, SDDM, iconos, cursor, wallpaper y teclado— con un solo comando.

### Instalación

Desde un NixOS recién instalado (cualquier desktop base):

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

Reinicia. Listo.

### Qué incluye

- **Niri + Noctalia** (v4, pineado) sobre Wayland, SDDM con tema sugar-dark recoloreable
- **`horus-theme`**: 11 temas rotados en OKLCH; un comando repinta todo en vivo
- **Dual GPU (laptops AMD+NVIDIA)**: PRIME offload declarativo, `horus-gpu-watch` cambia iGPU/dGPU y perfil de energía según AC/batería, apagado de dGPU por firmware
- **Laptop-first**: hibernación validada (fix de wakeup ACPI incluido), carga limitada al 80%, botón de encendido → lockscreen, RGB pre-SDDM
- **Privacidad declarativa**: DNS-over-TLS, firewall, MAC aleatoria
- **Gaming**: Steam, gamescope, MangoHud temado, `horus-fsr`
- **Boot silencioso** con branding Horus y generaciones limitadas

### Estructura

| Archivo | Rol |
|---|---|
| `configuration.nix` | Sistema base, boot, gráficos, privacidad |
| `metal.nix` | Hardware real (udev, hibernación, flatpaks) |
| `sddm.nix` | Tema SDDM con fondo/colores mutables |
| `horus-bin/` | Tooling (`horus-theme`, `horus-gpu`, `horus-power`…) |
| `bootstrap.sh` | Post-install de un comando |

El contenido (wallpapers, temas, branding) vive en [Horus-Project](https://github.com/Johankyuk/Horus-Project).

Hardware de referencia: ASUS TUF Gaming A16 (Ryzen 8040 + Radeon 780M + RTX 4050).

---

<a name="english"></a>
## English

NixOS flake that turns a clean install into a complete, themed, hardware-aware Niri + Noctalia desktop: dual-GPU management (iGPU/dGPU offload with firmware power-off), working hibernation, battery charge limit, keyboard RGB before login, and an OKLCH theme engine that recolors the whole system —compositor, shell, terminal, SDDM, icons, cursor, wallpaper and keyboard— with a single command.

### Install

From a freshly installed NixOS (any base desktop):

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

Reboot. Done.

### What's included

- **Niri + Noctalia** (v4, pinned) on Wayland, SDDM with a recolorable sugar-dark theme
- **`horus-theme`**: 11 OKLCH-rotated themes; one command repaints everything live
- **Dual GPU (AMD+NVIDIA laptops)**: declarative PRIME offload, `horus-gpu-watch` switches iGPU/dGPU and power profile on AC/battery, firmware-level dGPU power-off
- **Laptop-first**: validated hibernation (ACPI wakeup fix included), 80% charge limit, power button → lockscreen, pre-SDDM RGB
- **Declarative privacy**: DNS-over-TLS, firewall, MAC randomization
- **Gaming**: Steam, gamescope, themed MangoHud, `horus-fsr`
- **Silent boot** with Horus branding and limited generations

### Layout

| File | Role |
|---|---|
| `configuration.nix` | Base system, boot, graphics, privacy |
| `metal.nix` | Real hardware (udev, hibernation, flatpaks) |
| `sddm.nix` | SDDM theme with mutable background/colors |
| `horus-bin/` | Tooling (`horus-theme`, `horus-gpu`, `horus-power`…) |
| `bootstrap.sh` | One-command post-install |

Content (wallpapers, themes, branding) lives in [Horus-Project](https://github.com/Johankyuk/Horus-Project).

Reference hardware: ASUS TUF Gaming A16 (Ryzen 8040 + Radeon 780M + RTX 4050).
