#!/bin/sh
# SPDX-License-Identifier: MIT
# tests/smoke.sh PLATFORM...: each image has its identity files, storage path and shell, and
# a BusyBox image has no other shell. RUNTIME and IMAGE_PREFIX (default localhost/nas-sim) as in build.sh.
set -u
cd "$(dirname "$0")/.." || exit 1
rt=${RUNTIME:-$(command -v podman >/dev/null 2>&1 && echo podman || echo docker)}
prefix=${IMAGE_PREFIX:-localhost/nas-sim}
if [ "$#" -eq 0 ]; then for d in platforms/*/; do d=${d%/}; set -- "$@" "${d#platforms/}"; done; fi
fails=0
for p in "$@"; do
    expect=$(sed -n 's/^# expect: //p' "tests/expect/$p")
    if "$rt" run --rm "$prefix/$p" sh -c "set -e; for f in $expect; do test -e \"\$f\" || { echo \"missing \$f\"; exit 1; }; done
        $(sed -n 's/^# check: //p' "tests/expect/$p")"; then
        echo "nas-sim/$p: pass"
    else
        echo "nas-sim/$p: FAIL"
        fails=$((fails + 1))
    fi
done
exit "$fails"
