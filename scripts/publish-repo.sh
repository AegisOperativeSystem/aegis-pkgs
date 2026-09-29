#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_dir="${root}/repo/x86_64"
mkdir -p "${repo_dir}"

if [[ -n "${AEGIS_PACKAGE_DIR:-}" ]]; then
  cp -a "${AEGIS_PACKAGE_DIR}"/*.pkg.tar.zst "${repo_dir}/"
fi

if [[ -n "${AEGIS_KERNEL_TAG:-}" ]]; then
  gh release download "${AEGIS_KERNEL_TAG}" \
    --repo AegisOperativeSystem/aegis-kernel \
    --pattern '*.pkg.tar.zst' \
    --dir "${repo_dir}" \
    --clobber
fi

shopt -s nullglob
packages=("${repo_dir}"/*.pkg.tar.zst)
if [[ ${#packages[@]} -eq 0 ]]; then
  echo "no packages to publish" >&2
  exit 1
fi

rm -f "${repo_dir}/aegis.db" "${repo_dir}/aegis.db.tar.zst" \
  "${repo_dir}/aegis.files" "${repo_dir}/aegis.files.tar.zst" \
  "${repo_dir}/aegis.db.sig" "${repo_dir}/aegis.files.sig"
repo-add -R "${repo_dir}/aegis.db.tar.zst" "${packages[@]}"
rm -f "${repo_dir}/aegis.db" "${repo_dir}/aegis.files"
cp -f "${repo_dir}/aegis.db.tar.zst" "${repo_dir}/aegis.db"
cp -f "${repo_dir}/aegis.files.tar.zst" "${repo_dir}/aegis.files"

tag="x86_64"
if ! gh release view "${tag}" --repo AegisOperativeSystem/aegis-pkgs >/dev/null 2>&1; then
  gh release create "${tag}" \
    --repo AegisOperativeSystem/aegis-pkgs \
    --title "x86_64 repository" \
    --notes "Rolling pacman repository. Point Server at this release tag."
fi
shopt -s nullglob
assets=(
  "${repo_dir}"/*.pkg.tar.zst
  "${repo_dir}"/*.pkg.tar.zst.sig
  "${repo_dir}"/aegis.db
  "${repo_dir}"/aegis.db.tar.zst
  "${repo_dir}"/aegis.db.sig
  "${repo_dir}"/aegis.files
  "${repo_dir}"/aegis.files.tar.zst
  "${repo_dir}"/aegis.files.sig
)
gh release upload "${tag}" "${assets[@]}" \
  --repo AegisOperativeSystem/aegis-pkgs \
  --clobber
echo "published ${tag}"
