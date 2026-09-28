# Repository

`scripts/build-all.sh` runs `makepkg` in each `packages/*` directory as the `builder` user and creates `aegis.db.tar.zst` with `repo-add`.

`scripts/publish-repo.sh` rebuilds that database and uploads every file to the GitHub Release tagged `x86_64`. Pacman requests `aegis.db`. The script copies the zstd database to that exact asset name.

Set `AEGIS_KERNEL_TAG` to a tag in `aegis-kernel` to download `linux-aegis` into the same database before `repo-add`.

`scripts/export-keyring.sh` writes the public keyring files from a local GnuPG key. The private key stays in GitHub Actions secrets and in the operator's offline backup.

Until those files exist, `aegis-keyring` ships an empty keyring and the mirror uses `SigLevel = Optional TrustAll`. Switch to `Required` only after `pacman-key --populate aegis` succeeds.
