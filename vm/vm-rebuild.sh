#!/usr/bin/env bash
# Rebuild de la VM + regeneracion de run-vm-host.sh (qemu del host)
set -eu
cd ~/horus-nix/vm

# Flakes solo ven archivos trackeados: staging automatico (commits siguen manuales)
git add -A

nix build ..#nixosConfigurations.horus-vm.config.system.build.vm

# install derreferencia el store y fija permisos de una vez
rm -f run-vm-host.sh
install -m 755 "$(readlink -f result/bin/run-horus-vm 2>/dev/null || readlink -f result/bin/run-*-vm)" run-vm-host.sh
sed -i 's|exec /nix/store/[^ ]*/bin/qemu-system-x86_64|exec /usr/bin/qemu-system-x86_64|' run-vm-host.sh

# Guard: si el sed no aplico, mejor fallar ruidoso que bootear mal
grep -q 'exec /usr/bin/qemu-system-x86_64' run-vm-host.sh \
  || { echo "ERROR: run-vm-host.sh sigue con qemu de Nix"; exit 1; }
echo "✓ terminado"
