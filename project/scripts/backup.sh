#!/usr/bin/env bash
set -euo pipefail

mkdir -p backups

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backups/backup_${TIMESTAMP}.dump"

set -a
source .env
set +a

docker compose exec -T db pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -Fc > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"
