#!/bin/sh
# SPDX-License-Identifier: MIT
# busybox-rootfs.sh ROOT [PACKAGE...]: a root file system of unmodified Hummingbird packages,
# filesystem, glibc and busybox (plus any PACKAGE), where BusyBox provides sh and the tools.
# Runs in the Hummingbird builder image, as root.
set -eu
root=$1
shift
dnf -y -q --installroot "$root" --use-host-config --setopt=install_weak_deps=False \
    install filesystem glibc busybox "$@"
# bash comes in as a dependency of the base packages; keep it only if asked for.
case " $* " in *" bash "*) ;; *) rpm --root "$root" -e --nodeps bash ;; esac
rm -f "$root/usr/bin/sh" "$root/usr/bin/busybox.musl.static" "$root/usr/bin/udhcpc"
# Applets for every tool not already provided by a package that was asked for.
chroot "$root" /usr/bin/busybox --install -s /usr/bin
ln -sf busybox "$root/usr/bin/sh"
mkdir -p "$root/tmp" "$root/var/log" "$root/var/run" "$root/root"
chmod 1777 "$root/tmp"
rm -rf "$root/var/cache/dnf" "$root/var/lib/dnf"
