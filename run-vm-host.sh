#! /nix/store/v8llyqw71lygr2llhmcc8ya5bdlzq45v-bash-5.3p9/bin/bash

export PATH=/nix/store/cp7wjv1pl4wapfk48svvizxd089v9h0a-coreutils-9.11/bin${PATH:+:}$PATH

set -e

# Create an empty ext4 filesystem image. A filesystem image does not
# contain a partition table but just a filesystem.
createEmptyFilesystemImage() {
  local name=$1
  local size=$2
  local temp=$(mktemp)
  /nix/store/h6dhf64hz137g265n1v233jj78s73nqa-qemu-host-cpu-only-11.0.1/bin/qemu-img create -f raw "$temp" "$size"
  /nix/store/hharigj3x5fda73lw1vbn7fnv568iixn-e2fsprogs-1.47.4-bin/bin/mkfs.ext4 -L nixos "$temp"
  /nix/store/h6dhf64hz137g265n1v233jj78s73nqa-qemu-host-cpu-only-11.0.1/bin/qemu-img convert -f raw -O qcow2 "$temp" "$name"
  rm "$temp"
}

NIX_DISK_IMAGE=$(readlink -f "${NIX_DISK_IMAGE:-./horus.qcow2}") || test -z "$NIX_DISK_IMAGE"

if test -n "$NIX_DISK_IMAGE" && ! test -e "$NIX_DISK_IMAGE"; then
    echo "Disk image does not exist, creating the virtualisation disk image..."

    createEmptyFilesystemImage "$NIX_DISK_IMAGE" "1024M"

    echo "Virtualisation disk image created."
fi

# Create a directory for storing temporary data of the running VM.
if [ -z "$TMPDIR" ] || [ -z "$USE_TMPDIR" ]; then
    TMPDIR=$(mktemp -d nix-vm.XXXXXXXXXX --tmpdir)
fi



# Create a directory for exchanging data with the VM.
mkdir -p "$TMPDIR/xchg"







cd "$TMPDIR"





# Start QEMU.
exec /usr/bin/qemu-system-x86_64 -machine accel=kvm:tcg -cpu max \
    -name horus \
    -m 1024 \
    -smp 1 \
    -device virtio-rng-pci \
    -net nic,netdev=user.0,model=virtio -netdev user,id=user.0,"$QEMU_NET_OPTS" \
    -virtfs local,path=/nix/store,security_model=none,mount_tag=nix-store \
    -virtfs local,path="${SHARED_DIR:-$TMPDIR/xchg}",security_model=none,mount_tag=shared \
    -virtfs local,path="$TMPDIR"/xchg,security_model=none,mount_tag=xchg \
    -drive cache=writeback,file="$NIX_DISK_IMAGE",id=drive1,if=none,index=1,werror=report -device virtio-blk-pci,bootindex=1,drive=drive1,serial=root \
    -device virtio-keyboard \
    -usb \
    -device usb-tablet,bus=usb-bus.0 \
    -kernel ${NIXPKGS_QEMU_KERNEL_horus:-/nix/store/ri81pcn7dfnihqwsv3rfv41pc3lz8f36-nixos-system-horus-26.11.20260715.753cc8a/kernel} \
    -initrd /nix/store/a1r6qaxh49dmss73lifav6b84pgig9i0-initrd-linux-x86_64-unknown-linux-gnu-7.1.3/initrd \
    -append "$(cat /nix/store/ri81pcn7dfnihqwsv3rfv41pc3lz8f36-nixos-system-horus-26.11.20260715.753cc8a/kernel-params) init=/nix/store/ri81pcn7dfnihqwsv3rfv41pc3lz8f36-nixos-system-horus-26.11.20260715.753cc8a/init regInfo=/nix/store/m9s96j2hi0rahhdbcfmdnc435gn22f5h-closure-info/registration console=ttyS0,115200n8 console=tty0 $QEMU_KERNEL_PARAMS" \
    $QEMU_OPTS \
    "$@"
