# Database Backup Script (backup.sh)

This script automates the process of backing up PostgreSQL databases to an Amazon S3 bucket. It provides flexibility and customization options to meet your backup needs.

## Prerequisites

Before using this script, ensure you have the following installed and configured:

1. **PostgreSQL Client**: Ensure `pg_dump` is available on your system.
2. **AWS CLI**: AWS Command Line Interface must be installed and configured with the necessary permissions to access S3.
3. **Environment Variables**: Set the required environment variables as described below.

## Environment Variables

The script requires several environment variables to function correctly:

- `DB_SERVER`: The hostname or IP address of your PostgreSQL server.
- `DB_PORT` (optional): The port number on which the database is running. Default is 5432.
- `DB_USER`: The username used to connect to the database.
- `DB_PASSWORD`: The password for the database user.
- `DB_NAME`: The name of the database to back up.
- `S3_BUCKET`: The S3 bucket where backups will be stored.
- `S3_BUCKET_FOLDER` (optional): A subfolder within the S3 bucket. Default is an empty string.
- `AWS_REGION`: The AWS region where the S3 bucket is located.
- `BACKUP_PREFIX` (optional): A prefix to use for backup files. Default is 'backup'.
- `USE_ENDPOINT` (optional): Set to 'true' if you are using a custom S3 endpoint. Default is 'false'.
- `COMPRESSION_LEVEL` (optional): Compression level for the backup file. Default is 9 (max compression).

## Usage

1. **Set Environment Variables**:
   Before running the script, set the required environment variables in your shell session or in a `.env` file.

   ```sh
   export DB_SERVER="your_db_server"
   export DB_PORT="5432"
   export DB_USER="your_db_user"
   export DB_PASSWORD="your_db_password"
   export DB_NAME="your_db_name"
   export S3_BUCKET="your_s3_bucket"
   export S3_BUCKET_FOLDER="your_subfolder"
   export AWS_REGION="your_aws_region"
   ```

2. **Run the Script**:
   Execute the script from the command line.

   ```sh
   ./backup.sh
   ```

### Optional Parameters

- **TABLES**: If you want to back up specific tables instead of the entire database, set this variable with a comma-separated list of table names.

  ```sh
  export TABLES="table1,table2"
  ```

## Example

Here's an example of how to run the script to backup a single table:

```sh
export DB_SERVER="localhost"
export DB_PORT="5432"
export DB_USER="postgres"
export DB_PASSWORD="password"
export DB_NAME="mydatabase"
export S3_BUCKET="backup-bucket"
export S3_BUCKET_FOLDER="daily-backups/"
export AWS_REGION="us-east-1"
export TABLES="users"

./backup.sh
```

This will create a backup of the `users` table and upload it to the specified S3 bucket with the filename in the format `backup_mydatabase_users_YYYYMMDDHHMMSS.dump`.

## Log Output

The script includes logging functionality that outputs messages to the console. Errors are logged as "ERROR:" prefixed messages.

## Conclusion

This script provides a robust solution for automating PostgreSQL database backups to S3. By following the instructions in this README, you can easily configure and use it to meet your backup requirements.