# pg backup image

## Description

This image will run a backup of a postgres database, a full backup or just a set of tables.
After that will push the backup to an S3 bucket.

## Environment Variables

```bash
PGHOST                = Database hostname
PGPORT                = Database port number
PGUSER                = User name
PGPASSWORD            = Password
PGDATABASE            = Environment variable PGDATABASE is required
S3_BUCKET             = Environment variable S3_BUCKET is required
BACKUP_PREFIX         = S3 bucket prefix
AWS_REGION            = Environment variable AWS_REGION is required
PGDUMP_COMPRESSION    = pgdump compression level
AWS_ACCESS_KEY_ID     = AWS access key
AWS_SECRET_ACCESS_KEY = AWS access secret
```

## Usage Examples

### Use Default Compression Level

The script defaults level 9 pg_dump compression (PGDUMP_COMPRESSION=9):

```bash
./backup.sh
```

### Set a Specific Compression Level

To apply maximum compression:

```bash
export PGDUMP_COMPRESSION=9
./backup.sh
```

### Dump Specific Tables with Compression

```bash
export PGTABLES="table1,table2"
export PGDUMP_COMPRESSION=5

./backup.sh
```

This will dump `table1` and `table2` with pg_dump compression level `5`.