# nas-sim

Small container images that copy just enough of a consumer NAS's userland to test install
scripts and packaging in CI without booting the NAS's OS.

Each image provides the platform's identity files, its shell and tools (BusyBox or bash), its
storage paths, its boot-hook locations, and whether a container engine and systemd are present.

**Every file in these images is written by this project.** No vendor binaries, firmware or
copied configuration are included. They imitate a layout; they are not the vendor's system.

## What they can't tell you

The vendor's kernel and FUSE support, its app centre and web UI, and its permission model. Results
from these images should be labelled *simulated* and confirmed on the real OS before a release.

## Status

Being built. The first consumer is [sacdfs](https://github.com/aclater/sacdfs)'s installer.
