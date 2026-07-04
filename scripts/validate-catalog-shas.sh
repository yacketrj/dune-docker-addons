#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ADDONS_DIR="$ROOT_DIR/addons"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

FAILED=0
VERIFIED=0
MISSING=0

validate_entry() {
  local manifest="$1"
  local id version download_url expected_sha

  id="$(node -e "try { process.stdout.write(require('$manifest').id) } catch(_) {}")"
  version="$(node -e "try { process.stdout.write(require('$manifest').version) } catch(_) {}")"
  download_url="$(node -e "try { process.stdout.write(require('$manifest').downloadUrl) } catch(_) {}")"
  expected_sha="$(node -e "try { process.stdout.write(require('$manifest').sha256) } catch(_) {}")"

  if [[ -z "$id" || -z "$download_url" || -z "$expected_sha" ]]; then
    printf 'SKIP: %s (missing id, downloadUrl, or sha256)\n' "$(basename "$manifest")"
    MISSING=$((MISSING + 1))
    return
  fi

  local asset_file="$WORK_DIR/$id-$version.zip"
  printf '  %s v%s ... ' "$id" "$version"

  if ! curl -fsSL --max-time 60 -o "$asset_file" "$download_url" >/dev/null 2>&1; then
    printf 'FAIL (download failed)\n'
    FAILED=$((FAILED + 1))
    return
  fi

  local actual_sha
  actual_sha="$(sha256sum "$asset_file" | awk '{print $1}')"

  if [[ "$actual_sha" != "$expected_sha" ]]; then
    printf 'FAIL (SHA mismatch)\n'
    printf '    Expected: %s\n' "$expected_sha"
    printf '    Actual:   %s\n' "$actual_sha"
    FAILED=$((FAILED + 1))
  else
    printf 'OK\n'
    VERIFIED=$((VERIFIED + 1))
  fi
}

echo "Validating catalog SHA-256 entries..."
echo "Addon directory: $ADDONS_DIR"
echo

for manifest in "$ADDONS_DIR"/*.json; do
  [[ -f "$manifest" ]] || continue
  validate_entry "$manifest"
done

echo
echo "Results: $VERIFIED verified, $MISSING skipped, $FAILED failed"

if [[ "$FAILED" -gt 0 ]]; then
  echo "FAILURE: $FAILED catalog entry SHA(s) do not match their release zip."
  exit 1
fi

echo "All catalog SHAs verified."
