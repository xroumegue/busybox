#!/bin/bash

[ ! -f .config ] || make riscv_defconfig

make -j16 install

mkdir -p _install/etc
cat > _install/etc/inittab <<EOF
#/etc/inittab
# Startup the system
::sysinit:/bin/mkdir /proc
::sysinit:/bin/mkdir /sys
::sysinit:/bin/mkdir /dev
::sysinit:/bin/mount -t proc none /proc
::sysinit:/bin/mount -t sysfs sysfs /sys
::sysinit:/bin/mount -t devtmpfs devtmpfs /dev
/dev/console::sysinit:-/bin/ash
EOF

rm -f _install/sbin/init
rm -f _install/init
cd _install || exit
ln -s /bin/busybox init

find . | cpio -o -H newc | gzip > ../ramdisk.cpio.gz
cd - || exit

echo "Ramdisk Generated in $(pwd)/ramdisk.cpio.gz"

