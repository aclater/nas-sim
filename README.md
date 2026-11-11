# nas-sim

Small container images that copy just enough of a consumer NAS's userland to test install
scripts and packaging in CI without booting the NAS's OS.

Each image provides the platform's identity files, its shell and tools (BusyBox or bash), its
storage paths, its boot-hook locations, and labels saying whether a container engine and systemd
are present on the real system.

**Every file in these images that is not from an unmodified package is written by this project.**
No vendor binaries, firmware or copied configuration are included. The identity files hold only
the few keys install scripts look for, with made-up values. They imitate a layout; they are not
the vendor's system.

## Images

Published from `main` as `ghcr.io/aclater/nas-sim/<platform>:latest` (and `:<commit>`), x86_64.

| Platform | Image | Shell and tools | Base | Identity files, paths and stand-ins |
|---|---|---|---|---|
| Synology DSM | `synology` | bash | UBI 9 minimal | `/etc.defaults/VERSION`, `/etc/VERSION`, `/etc/synoinfo.conf`, `/usr/syno`, `/volume1`, `/usr/local/etc/rc.d`; `esynoscheduler` stand-in (a task list) |
| QNAP QTS | `qnap` | BusyBox (`sh` is BusyBox ash), bash and curl present | Hummingbird glibc + busybox | `/etc/config/uLinux.conf`, `/share/CACHEDEV1_DATA/Public`, `/etc/init.d`; `getcfg`, `setcfg`, `hal_app` stand-ins |
| ASUSTOR ADM | `asustor` | BusyBox only, curl present | Hummingbird glibc + busybox | `/etc/nas.conf`, `/usr/builtin`, `/usr/local/etc/init.d`, `/volume1` |
| TerraMaster TOS | `terramaster` | bash | UBI 9 minimal | `/etc/tos/conf/tos.conf`, `/Volume1` |
| UGREEN UGOS Pro | `ugreen` | dash as `sh`, bash present | Fedora minimal | `/ugreen`, `/volume1` |
| Netgear ReadyNAS OS 6 | `readynas` | bash (the real system's `sh` is dash) | UBI 7 (glibc 2.17; the real one has 2.19) | `/frontview`, `/data` |
| OpenMediaVault | `openmediavault` | dash as `sh`, bash present | Fedora minimal | `/etc/openmediavault/config.xml`, `/srv/dev-disk-by-uuid-0000` |
| TrueNAS SCALE | `truenas` | dash as `sh`, bash present | Fedora minimal | `/usr/bin/midclt` stand-in, `/mnt/tank` |
| Unraid | `unraid` | bash | UBI 9 minimal | `/etc/unraid-version`, `/boot/config/go`, `/mnt/user`, `/mnt/disk1` |

The stand-in commands in `common/bin/` accept only the few arguments documented at their top;
they keep state in plain files and never do what the real command does.

Labels on every image: `io.github.aclater.nas-sim.platform`, `.shell`, `.systemd` and
`.container-engine`. systemd is never running in these containers, and no container engine is
installed; the labels describe the real system.

## Use

```sh
./build.sh                 # all images, as localhost/nas-sim/<platform> (podman or docker)
./build.sh qnap            # one
./tests/smoke.sh           # identity files, paths and shell of each image
podman run --rm -it localhost/nas-sim/asustor
```

For the QNAP image, add `--tmpfs /tmp/config` to stand in for the mounted configuration
partition. For FUSE inside an image: `--device /dev/fuse --cap-add SYS_ADMIN`.

## What they can't tell you

The vendor's kernel and FUSE support, its app centre and web UI, its permission model, its
storage stack, and anything systemd or a container engine would do. Results from these images
must be labelled *simulated* and confirmed on the real OS before a release.

## Third-party software

The images are built only from unmodified packages of Red Hat and Fedora: the base images
`registry.access.redhat.com/ubi9/ubi-minimal`, `registry.access.redhat.com/ubi7/ubi`,
`registry.fedoraproject.org/fedora-minimal` (44) and `registry.access.redhat.com/hi/core-runtime`
(Hummingbird, Red Hat's hardened images built from Fedora sources; its builder variant installs
glibc, busybox, bash and curl into the BusyBox images), each pinned by digest in its
`Containerfile`, plus packages from their own repositories. No package is patched or rebuilt
here.

Those packages keep their own licences (BusyBox is GPL-2.0-only; glibc is LGPL-2.1-or-later;
the others as each package states, `rpm -q --qf '%{LICENSE}\n' <package>` in an image), and UBI
content is also under the [Red Hat UBI EULA](https://www.redhat.com/licenses/EULA_Red_Hat_Universal_Base_Image_English_20190422.pdf).
Their sources: UBI and Hummingbird source RPMs from Red Hat
([UBI sources](https://access.redhat.com/articles/4238681),
[Hummingbird source containers](https://hummingbird-project.io/docs/using/overview/)), and
Fedora's from [src.fedoraproject.org](https://src.fedoraproject.org/). This project's own files
are under the MIT licence ([LICENSE](LICENSE)). The images' `org.opencontainers.image.licenses`
label is `MIT AND GPL-2.0-only`.
