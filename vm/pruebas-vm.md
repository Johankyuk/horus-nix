# Guion de prueba — primer boot de Horus/NixOS

## Lanzar (memoria y cores para que no sufra)
QEMU_OPTS="-m 8192 -smp 6" ./result/bin/run-horus-vm

## Dentro de la VM (login: kyu — pedirá crear contraseña o entra directo según config)
uname -r                    # ¿dice cachyos? → kernel correcto
resolvectl status | head    # ¿DNSOverTLS: yes? → horus-privacy vive
systemctl status battery-limit   # ¿activo? (fallará el sysfs en VM, normal)
which noctalia horus-theme  # ¿existen los comandos empaquetados?
noctalia                    # veredicto del wrapper quickshell

## Notas
- SDDM debería recibirte gráficamente; si cae a consola, anotar error
- NVIDIA/PRIME no funcionan en QEMU (GPU emulada) — ignorar errores de eso
- Todo lo que truene: anotar mensaje exacto, es la lista de trabajo del porteo
