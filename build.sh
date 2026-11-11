#!/bin/sh
# SPDX-License-Identifier: MIT
# build.sh [PLATFORM...]: build the images as localhost/nas-sim/<platform> (all by default).
# RUNTIME: docker or podman (default: podman if present, else docker).
set -eu
cd "$(dirname "$0")"
rt=${RUNTIME:-$(command -v podman >/dev/null 2>&1 && echo podman || echo docker)}
if [ "$#" -eq 0 ]; then for d in platforms/*/; do d=${d%/}; set -- "$@" "${d#platforms/}"; done; fi
for p in "$@"; do
    echo "== nas-sim/$p"
    "$rt" build -q -f "platforms/$p/Containerfile" -t "localhost/nas-sim/$p" .
done
