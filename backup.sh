#!/bin/bash

# Config
TIMESTAMP=$(date +"%F-%H-%M")
HOSTNAME=$(hostname)
BACKUP_DIR="/opt/backup"
LOG_FILE="/var/log/backup_script.log"
S3_BUCKET="my-ec2-backups-bucket"
BACKUP_FILE="$BACKUP_DIR/${HOSTNAME}_backup_$TIMESTAMP.tar.gz"

# Create log file if it doesn't exist
touch $LOG_FILE

echo "[$(date)] Starting backup..." >> $LOG_FILE

# Create backup archive
tar -czf $BACKUP_FILE /etc /home /var/www >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup archive created: $BACKUP_FILE" >> $LOG_FILE
else
    echo "[$(date)] Error during tar operation!" >> $LOG_FILE
    exit 1
fi

# Upload to S3
aws s3 cp $BACKUP_FILE s3://$S3_BUCKET/ >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup uploaded to S3: $S3_BUCKET" >> $LOG_FILE
else
    echo "[$(date)] S3 upload failed!" >> $LOG_FILE
    exit 1
fi

# Cleanup
rm -f $BACKUP_FILE
echo "[$(date)] Temporary backup file removed." >> $LOG_FILE