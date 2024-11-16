#!/bin/bash
set -e

# Environment variables
: "${PGHOST:?Environment variable PGHOST is required}"
: "${PGPORT:=5432}"
: "${PGUSER:?Environment variable PGUSER is required}"
: "${PGPASSWORD:?Environment variable PGPASSWORD is required}"
: "${PGDATABASE:?Environment variable PGDATABASE is required}"
: "${S3_BUCKET:?Environment variable S3_BUCKET is required}"
: "${BACKUP_PREFIX:=backup}"
: "${AWS_REGION:?Environment variable AWS_REGION is required}"
: "${PGDUMP_COMPRESSION:=9}" # Default compression level (9 = max compression)

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Create a temporary directory for table dumps
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Perform the database dump
echo "Dumping database [$PGDATABASE]..."
if [ -z "${PGTABLES}" ]; then
  # Dump the entire database into a single file
  BACKUP_FILE="${BACKUP_PREFIX}_${TIMESTAMP}_full.sql.gz"
  pg_dump --compress="$PGDUMP_COMPRESSION" -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE" | gzip > "$BACKUP_FILE"
else
  # Dump each table into a separate file
  IFS=',' read -ra TABLES <<< "$PGTABLES"
  for TABLE in "${TABLES[@]}"; do
    TABLE_BACKUP_FILE="${TEMP_DIR}/${BACKUP_PREFIX}_${TIMESTAMP}_${TABLE}.sql.gz"
    echo "Dumping table $TABLE..."
    pg_dump --compress="$PGDUMP_COMPRESSION" -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE" -t "$TABLE" | gzip > "$TABLE_BACKUP_FILE"
  done

  # Combine all table dumps into a single archive
  BACKUP_FILE="${BACKUP_PREFIX}_${TIMESTAMP}_tables.zip"
  zip -j "$BACKUP_FILE" "${TEMP_DIR}"/*.sql.gz
fi

# Upload to S3
echo "Uploading to S3..."
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/$BACKUP_FILE" --region "$AWS_REGION"

# Cleanup
rm -f "$BACKUP_FILE"

echo "Backup completed successfully!"
