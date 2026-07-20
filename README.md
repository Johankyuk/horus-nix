# Horus

**A better Noctalia for laptops.**

NixOS flake que convierte una instalación limpia en un escritorio Niri + Noctalia completo, temado y consciente del hardware: gestión dual-GPU (iGPU/dGPU offload con apagado por firmware), hibernación funcional, límite de carga de batería, RGB del teclado antes del login, y un motor de temas OKLCH que recolorea todo el sistema —compositor, shell, terminal, SDDM, iconos, cursor, wallpaper y teclado— con un solo comando.

## Instalación

Desde un NixOS recién instalado (cualquier desktop base):

```bash
curl -L https://raw.githubusercontent.com/Johankyuk/horus-nix/main/bootstrap.sh | bash
```

Reinicia. Listo.

## Qué incluye

- **Niri + Noctalia** (v4, pineado) sobre Wayland, SDDM con tema sugar-dark recoloreable
- **`horus-theme`**: 11 temas rotados en OKLCH; un comando repinta todo en vivo
- **Dual GPU (laptops AMD+NVIDIA)**: PRIME offload declarativo, `horus-gpu-watch` cambia iGPU/dGPU y perfil de energía según AC/batería, apagado de dGPU por firmware
- **Laptop-first**: hibernación validada (fix de wakeup ACPI incluido), carga limitada al 80%, botón de encendido → lockscreen, RGB pre-SDDM
- **Privacidad declarativa**: DNS-over-TLS, firewall, MAC aleatoria
- **Gaming**: Steam, gamescope, MangoHud temado, `horus-fsr`
- **Boot silencioso** con branding Horus y generaciones limitadas

## Estructura

| Archivo | Rol |
|---|---|
| `configuration.nix` | Sistema base, boot, gráficos, privacidad |
| `metal.nix` | Hardware real (udev, hibernación, flatpaks) |
| `sddm.nix` | Tema SDDM con fondo/colores mutables |
| `horus-bin/` | Tooling (`horus-theme`, `horus-gpu`, `horus-power`…) |
| `bootstrap.sh` | Post-install de un comando |

El contenido (wallpapers, temas, branding) vive en [Horus-Project](https://github.com/Johankyuk/Horus-Project).

Hardware de referencia: ASUS TUF Gaming A16 (Ryzen 8040 + Radeon 780M + RTX 4050).
