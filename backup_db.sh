#!/usr/bin/env bash
# =====================================================================
# ORDRO daily database backup.
# Makes a safe snapshot of the database, compresses it, and keeps the
# most recent 14 backups. Designed to be run once a day by cron.
# Uses Python's built-in SQLite backup (safe while the app is running),
# so no extra software is needed.
# =====================================================================
set -euo pipefail

PERSIST="${ORDRO_DATA_DIR:-/opt/ordro/persist}"
DB="$PERSIST/data/ordro.db"
BACKUP_DIR="$PERSIST/backups"
KEEP=14

mkdir -p "$BACKUP_DIR"

if [ ! -f "$DB" ]; then
  echo "$(date '+%F %T')  ERROR: database not found at $DB"
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$BACKUP_DIR/ordro-$STAMP.db"

# Safe online backup using Python's sqlite3 (works while ORDRO is running).
python3 - "$DB" "$OUT" <<'PY'
import sqlite3, sys
src_path, out_path = sys.argv[1], sys.argv[2]
src = sqlite3.connect(src_path)
dst = sqlite3.connect(out_path)
with dst:
    src.backup(dst)
dst.close(); src.close()
PY

gzip -f "$OUT"

# Keep only the newest $KEEP backups; delete older ones.
ls -1t "$BACKUP_DIR"/ordro-*.db.gz 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f

echo "$(date '+%F %T')  Backup OK -> ${OUT}.gz"
