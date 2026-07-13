#!/usr/bin/env bash
# nas-sync — rsync your config backups (and pass store) to a NAS or any rsync target.
#
# Configure in ~/.zshrc.local (or a crontab):
#   export NAS_DEST="/mnt/nas/backups/$(hostname)"      # a mounted share (Synology = SMB/CIFS)
#   # ...or an ssh target if your NAS allows it:  export NAS_DEST="user@nas:/volume1/backups"
#   export NAS_SYNC_PATHS="$HOME/backup $HOME/.password-store"   # optional; these are the defaults
#
# Usage:  nas-sync         sync now
#         nas-sync -n      preview only (rsync --dry-run)
# Additive by design — it never deletes anything on the destination.
set -uo pipefail

dry=0
case "${1:-}" in
  -n|--dry-run) dry=1; shift ;;
  -h|--help)    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
esac

command -v rsync >/dev/null 2>&1 || { echo "nas-sync: rsync is required" >&2; exit 1; }

dest="${NAS_DEST:-}"
[ -n "$dest" ] || {
  echo "nas-sync: set NAS_DEST in ~/.zshrc.local (e.g. /mnt/nas/backups or user@nas:/path)" >&2
  exit 2
}

# sources: explicit override, else sensible defaults
if [ -n "${NAS_SYNC_PATHS:-}" ]; then
  # shellcheck disable=SC2206  # deliberate word-split on spaces
  paths=(${NAS_SYNC_PATHS})
else
  paths=("$HOME/backup")
  [ -d "$HOME/.password-store" ] && paths+=("$HOME/.password-store")
fi
[ "${#paths[@]}" -eq 0 ] && { echo "nas-sync: no source paths configured"; exit 0; }

rsync_args=(-ah)                       # always non-empty → safe under `set -u`
[ "$dry" -eq 1 ] && rsync_args+=(--dry-run)

rc=0
for src in "${paths[@]}"; do
  [ -e "$src" ] || { echo "nas-sync: skip $src (not found)"; continue; }
  echo "→ rsync $src  ⇒  ${dest%/}/"
  rsync "${rsync_args[@]}" "$src" "${dest%/}/" || { echo "nas-sync: rsync of $src failed" >&2; rc=1; }
done
exit "$rc"
