#!/bin/bash

# Environment variables
: "${DB_SERVER:?Environment variable DB_SERVER is required}"
: "${DB_PORT:=5432}"
: "${DB_USER:?Environment variable DB_USER is required}"
: "${DB_PASSWORD:?Environment variable DB_PASSWORD is required}"
: "${DB_NAME:?Environment variable DB_NAME is required}"
: "${S3_BUCKET:?Environment variable S3_BUCKET is required}"
: "${S3_BUCKET_FOLDER:=''}"
: "${AWS_REGION:?Environment variable AWS_REGION is required}"
: "${BACKUP_PREFIX:=backup}"
: "${USE_ENDPOINT:=false}"
: "${COMPRESSION_LEVEL:=9}" # Default compression level (9 = max compression)

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
  log "ERROR: $1"
}

# Convert USE_ENDPOINT to lowercase for case-insensitive comparison
USE_ENDPOINT=$(echo "$USE_ENDPOINT" | tr '[:upper:]' '[:lower:]')

# Validate and set default values
S3_BUCKET_FOLDER="${S3_BUCKET_FOLDER:='/'}"

# Generate timestamp
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

# Function to perform the database dump
dump_database() {
  local table=$1
  log "Dumping ${table:-entire} database [$DB_NAME]..."

  local command="pg_dump -Fc --compress=$COMPRESSION_LEVEL -h $DB_SERVER -p $DB_PORT -U $DB_USER"
  
  if [ "$table" ]; then
    command+=" -t $table"
  else
    command+=" $DB_NAME"
  fi

  command+=" $PG_DUMP_EXTRA_OPTIONS"

  command+=" | aws s3 cp - "

  if [ "$USE_ENDPOINT" = "true" ]; then
     command+="--endpoint='https://${S3_BUCKET}' s3://${S3_BUCKET_FOLDER}${BACKUP_PREFIX}_${DB_NAME}_$(echo $table | tr '_' '-')_$TIMESTAMP.dump"
  else
    command+="s3://${S3_BUCKET}/${S3_BUCKET_FOLDER}${BACKUP_PREFIX}_${DB_NAME}_$(echo $table | tr '_' '-')_$TIMESTAMP.dump"
  fi
  command+=" --region $AWS_REGION"

  if ! eval "$command"; then
    log_error "Failed to execute -> $command"
    exit 1
  fi
}

# Perform the database dump
if [ -z "${TABLES}" ]; then
  dump_database
else
  IFS=',' read -ra TABLES <<< "$TABLES"
  for TABLE in "${TABLES[@]}"; do
    dump_database "$TABLE"
  done
fi

log "Backup completed."