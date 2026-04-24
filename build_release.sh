#!/usr/bin/env bash
# Build TENDL 2023 cross sections, tar each nuclide, and optionally upload
# them to a GitHub release.
#
# Usage (run from repo root):
#   ./build_release.sh              # build + tar only
#   ./build_release.sh 1.0.0        # build + tar + upload to release tag 1.0.0
#   TAG=1.0.0 ./build_release.sh    # same, via env var

set -euo pipefail

TAG="${1:-${TAG:-}}"
OUT_DIR="tendl-2023-arrow"
GH_REPO="fusion-neutronics/cross_section_data_tendl_2023_arrow"

echo "==> converting TENDL 2023 neutron data into $OUT_DIR/"
convert-tendl --release 2023

tar_arrows () {
  local dir="$1"
  echo "==> tarring arrow files/folders in $dir"
  (
    cd "$dir"
    shopt -s nullglob
    for d in *.arrow; do tar -cf "${d}.tar" "$d"; done
  )
}
tar_arrows "$OUT_DIR/neutron"

echo
echo "Done. Artifacts ready under $OUT_DIR/."

if [[ -n "$TAG" ]]; then
  echo
  echo "==> uploading to release $TAG on $GH_REPO"
  shopt -s nullglob
  neutron_tars=("$OUT_DIR"/neutron/*.arrow.tar)
  shopt -u nullglob
  [[ ${#neutron_tars[@]} -gt 0 ]] && gh release upload "$TAG" "${neutron_tars[@]}" --repo "$GH_REPO" --clobber
  [[ -f "$OUT_DIR/index.txt" ]] && gh release upload "$TAG" "$OUT_DIR/index.txt" --repo "$GH_REPO" --clobber
  echo "==> upload complete"
else
  echo
  echo "No TAG given. To upload, re-run with a tag (./build_release.sh <TAG>) or:"
  echo "  export TAG=<your-tag>"
  echo "  gh release upload \$TAG $OUT_DIR/neutron/*.arrow.tar --repo $GH_REPO --clobber"
  echo "  gh release upload \$TAG $OUT_DIR/index.txt           --repo $GH_REPO --clobber"
fi
