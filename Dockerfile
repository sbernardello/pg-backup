FROM python:3.12-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN pip install --no-cache-dir awscli

# Set up work directory
WORKDIR /app

# Add the backup script
COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

# Set default command
CMD ["/app/backup.sh"]