The private signing key never belongs in git.

`scripts/export-keyring.sh` writes `aegis.gpg`, `aegis-trusted`, and `aegis-revoked` from the local public key. Those three files are the only keyring inputs, and `aegis-keyring` packages them.
