#!/bin/sh
# Copyright 2026 Ye Zicheng
# SPDX-License-Identifier: Apache-2.0
# Pack a locally built OpenHarmony standard system. This script does not
# download a guest image, and it refuses HarmonyOS commercial input.
set -eu

cd "$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

for arg in "$@"; do
  case "$arg" in
    *harmonyos*|*HarmonyOS*|*huawei.com*)
      echo "Refusing a HarmonyOS or Huawei commercial input." >&2
      exit 2
      ;;
    *macos*|*darwin*|*iOS*|*ios*)
      echo "Refusing an Apple system image." >&2
      exit 2
      ;;
  esac
done

out=${OHOS_IMAGES:-}
if [ -z "$out" ] || [ ! -d "$out" ]; then
  cat >&2 <<'EOF'
No OpenHarmony image directory is available (OHOS_IMAGES is unset).

This script will not download a HarmonyOS commercial package, a Huawei update,
or a third-party disk image and republish it. It will not write a placeholder
archive.

A from-source OpenHarmony standard system (product linkspan_slim, with bm and
aa) was not built here. The upstream standard-system build asks for about
32 GiB of RAM and 16 cores. This host has 4 vCPU and 16 GiB of RAM, which is
below that, so no image was produced. olympium-openharmony stays unpublished.
EOF
  exit 2
fi

for need in system.img vendor.img userdata.img; do
  if [ ! -f "$out/$need" ]; then
    echo "OpenHarmony output is missing $need. Refusing to pack a partial image." >&2
    exit 2
  fi
done

identity=${OHOS_IDENTITY_TEXT:-}
if [ -z "$identity" ] && [ -f "$out/EDITION" ]; then
  identity=$(cat "$out/EDITION")
fi
printf '%s' "$identity" | grep -q -i 'openharmony' || {
  echo "The image identity does not say OpenHarmony. Refusing to pack it." >&2
  exit 2
}
printf '%s' "$identity" | grep -q -i 'harmonyos' && {
  echo "Refusing a HarmonyOS commercial image." >&2
  exit 2
}

arch=${1:-$(uname -m)}
case "$arch" in
  x86_64|aarch64) ;;
  *)
    echo "No OpenHarmony slim asset is defined for $arch." >&2
    exit 2
    ;;
esac

if [ ! -x "$out/bin/hdc" ] && [ ! -f "$out/hdc" ]; then
  echo "The image directory has no hdc client. Refusing to pack a runtime that cannot install a HAP." >&2
  exit 2
fi

stage=$(mktemp -d)
cleanup() { rm -rf "$stage"; }
trap cleanup EXIT
mkdir -p "$stage/bin"
cp "$out/system.img" "$out/vendor.img" "$out/userdata.img" "$stage/"
if [ -f "$out/bin/hdc" ]; then
  cp "$out/bin/hdc" "$stage/bin/hdc"
elif [ -f "$out/hdc" ]; then
  cp "$out/hdc" "$stage/bin/hdc"
fi
chmod 755 "$stage/bin/hdc"
gcc -O2 -o "$stage/bin/linkspan-surface" bridge/linkspan-surface.c
cp bridge/linkspan-runtime.sh "$stage/bin/linkspan-runtime"
chmod 755 "$stage/bin/linkspan-runtime"
cat > "$stage/EDITION" <<EOF
openharmony-slim 0.1.0 developer-mode
arch ${arch}
EOF
cat > "$stage/NOTICE" <<'EOF'
This archive is an OpenHarmony standard system. It is not HarmonyOS, and it
is not relicensed as Apache-2.0. Third-party components keep their own licenses.
No Huawei signing key is included.
EOF
mkdir -p dist
archive="dist/openharmony-slim-${arch}.tar.gz"
tar -C "$stage" -czf "$archive" .
sha256sum "$archive" | tee "dist/openharmony-slim-${arch}.sha256"
echo "Wrote $archive"
echo "Boot the image and read const.product.os.dist.name with hdc before publishing it."
