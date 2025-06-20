#!/bin/bash

# Variables
S3_BUCKET="my-ec2-backups-bucket"
BACKUP_FILE="$1"
RESTORE_DIR="/opt/backup/restore"
LOG_FILE="/var/log/restore_script.log"

mkdir -p $RESTORE_DIR

echo "[$(date)] Starting restore..." >> $LOG_FILE

# Download from S3
aws s3 cp s3://$S3_BUCKET/$BACKUP_FILE $RESTORE_DIR/ >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "[$(date)] Failed to download backup from S3." >> $LOG_FILE
    exit 1
fi

# Extract
tar -xzf $RESTORE_DIR/$BACKUP_FILE -C / >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] Restore completed successfully." >> $LOG_FILE
else
    echo "[$(date)] Restore failed!" >> $LOG_FILE
    exit 1
fi