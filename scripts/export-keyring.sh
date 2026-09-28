#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
key_id="${1:?fingerprint or key id}"
out="${root}/keys"
mkdir -p "${out}"
gpg --armor --export "${key_id}" > "${out}/aegis.gpg"
printf '%s:4:\n' "${key_id}" > "${out}/aegis-trusted"
: > "${out}/aegis-revoked"
echo "wrote ${out}"
