# aegis-pkgs

PKGBUILDs and the rolling pacman repository for Aegis OS.

| Package | Contents |
| --- | --- |
| `aegis-shell` | GTK4 panel |
| `aegis-installer` | Live installer, polkit policy |
| `aegis-pkg` | Pacman front end |
| `aegis-session` | labwc session, theme, os-release |
| `aegis-mirrorlist` | Repository server entry |
| `aegis-keyring` | Public signing key, when `keys/` is populated |

```ini
[aegis]
SigLevel = Optional TrustAll
Server = https://github.com/AegisOperativeSystem/aegis-pkgs/releases/download/x86_64
```

`aegis-mirrorlist` appends that block. After the keyring is real, switch to the snippet in `/usr/share/aegis/pacman/aegis-signed.conf`.

```bash
AEGIS_OS_PATH=../aegis-os ./scripts/build-all.sh ./repo/x86_64
./scripts/publish-repo.sh
```

The repository workflow builds packages in an Arch container and uploads them to the `x86_64` release. A kernel release dispatches `index-kernel` so `linux-aegis` is copied into the same database.

See [docs/repository.md](docs/repository.md).
