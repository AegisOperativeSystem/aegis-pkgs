#!/usr/bin/env bash
set -euo pipefail

dest="${1:?destination directory}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${dest}"

if [[ "$(id -u)" -eq 0 ]]; then
  if ! id builder >/dev/null 2>&1; then
    useradd -m builder
  fi
  printf 'builder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/builder
  chmod 440 /etc/sudoers.d/builder
  chown -R builder:builder "${root}" "${dest}"
  if [[ -n "${AEGIS_OS_PATH:-}" ]]; then
    chown -R builder:builder "${AEGIS_OS_PATH}"
  fi
  exec su builder -c "AEGIS_OS_PATH='${AEGIS_OS_PATH:-}' '${root}/scripts/build-all.sh' '${dest}'"
fi

order=(
  aegis-keyring
  aegis-mirrorlist
  aegis-shell
  aegis-dock
  aegis-tour
  aegis-pkg
  aegis-installer
  aegis-session
)
for name in "${order[@]}"; do
  dir="${root}/packages/${name}"
  [[ -f "${dir}/PKGBUILD" ]] || continue
  (cd "${dir}" && makepkg -f --noconfirm --skipchecksums --nodeps)
  cp -a "${dir}"/*.pkg.tar.zst "${dest}/"
  rm -rf "${dir}/src" "${dir}/pkg"
done

repo-add -R "${dest}/aegis.db.tar.zst" "${dest}"/*.pkg.tar.zst
cp -f "${dest}/aegis.db.tar.zst" "${dest}/aegis.db"
cp -f "${dest}/aegis.files.tar.zst" "${dest}/aegis.files"
echo "repository index written to ${dest}"
