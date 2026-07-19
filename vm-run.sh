#!/usr/bin/env bash
# Arranque de la VM con las opciones estandar
cd ~/horus-nix
QEMU_OPTS="-m 8192 -smp 8 -serial mon:stdio -vga none -device virtio-vga-gl -display gtk,gl=on" \
  exec ./run-vm-host.sh "$@"
