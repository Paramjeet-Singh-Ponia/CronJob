#!/bin/bash

# Set timezone to India
export TZ=Asia/Kolkata

# Database credentials (use environment variables to make it more flexible)
DB_NAME=${DB_NAME:-mmt}
  CREDENTIAL_PATH=${CREDENTIAL_PATH:-/root/.my.cnf}  # Default credential file path
#CREDENTIAL_PATH="../mysql_Dump/.my.cnf"

# Tables to be dumped (space-separated)
TABLES=("test1" "testTable2" )  # Replace with your table names

# Dump location (can be mounted as a volume)
DUMP_DIR=${DUMP_DIR:-/app/dumps}  # Inside the container

# Log file location (create a new log file for each day)
LOG_FILE="${DUMP_DIR}/backup_$(date +'%Y-%m-%d').log"
# Create dump directory if it doesn't exist
mkdir -p "${DUMP_DIR}"

# Check if credential file exists
if [ ! -f "${CREDENTIAL_PATH}" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Error: MySQL credentials file not found at ${CREDENTIAL_PATH}" >> "${LOG_FILE}"
    exit 1
fi

# Check if dump directory is writable
if [ ! -w "${DUMP_DIR}" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Error: Dump directory ${DUMP_DIR} is not writable" >> "${LOG_FILE}"
    exit 1
fi

# Check if tables are provided
if [ ${#TABLES[@]} -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - No tables specified for backup" >> "${LOG_FILE}"
    exit 0
fi

# Log start of the process
echo "Backup started at $(date +'%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"

# Iterate over each table and dump data
for TABLE in "${TABLES[@]}"; do
  DUMP_FILE="${DUMP_DIR}/${TABLE}_$(date +'%Y-%m-%d_%H-%M').sql"

  # Dump the table
  mysqldump --defaults-file="${CREDENTIAL_PATH}" --no-tablespaces --skip-column-statistics "${DB_NAME}" "${TABLE}" > "${DUMP_FILE}" 2>> "${LOG_FILE}"

  # Check for success or failure and log it
  if [ $? -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backup successful for table '${TABLE}': ${DUMP_FILE}" >> "${LOG_FILE}"
  else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backup failed for table '${TABLE}'!" >> "${LOG_FILE}"
  fi
done

## Log end of the process
echo "Backup completed at $(date +'%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"


# Check for old .sql files (older than 5 days)
OLD_SQL_FILES=$(find "${DUMP_DIR}" -name "*.sql" -type f -mtime +5)
if [ -z "$OLD_SQL_FILES" ]; then
  echo "$(date +'%Y-%m-%d %H:%M:%S') - No .sql files older than 5 days found for cleanup" >> "${LOG_FILE}"
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Found .sql files older than 5 days for cleanup" >> "${LOG_FILE}"
  find "${DUMP_DIR}" -name "*.sql" -type f -mtime +5 -exec rm -f {} \;
  SQL_CLEANUP_STATUS=$?
fi

# Check for old .log files (older than 5 days)
OLD_LOG_FILES=$(find "${DUMP_DIR}" -name "backup_*.log" -type f -mtime +5)
if [ -z "$OLD_LOG_FILES" ]; then
  echo "$(date +'%Y-%m-%d %H:%M:%S') - No .log files older than 5 days found for cleanup" >> "${LOG_FILE}"
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Found .log files older than 5 days for cleanup" >> "${LOG_FILE}"
  find "${DUMP_DIR}" -name "*.log" -type f -mtime +5 -exec rm -f {} \;
  LOG_CLEANUP_STATUS=$?
fi

# Log the result of the cleanup
if [ ${SQL_CLEANUP_STATUS:-0} -eq 0 ] && [ ${LOG_CLEANUP_STATUS:-0} -eq 0 ]; then
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Cleanup successful: Removed .sql and .log files older than 5 days" >> "${LOG_FILE}"
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Cleanup failed!" >> "${LOG_FILE}"
fi


## Check for old .sql files (older than 3 minutes)--> for Testing
#OLD_SQL_FILES=$(find "${DUMP_DIR}" -name "*.sql" -type f -mmin +3)
#if [ -z "$OLD_SQL_FILES" ]; then
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - No .sql files older than 3 minutes found for cleanup" >> "${LOG_FILE}"
#else
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - Found .sql files older than 3 minutes for cleanup" >> "${LOG_FILE}"
#  find "${DUMP_DIR}" -name "*.sql" -type f -mmin +3 -exec rm -f {} \;
#  SQL_CLEANUP_STATUS=$?
#fi
#
## Check for old .log files (older than 3 minutes)
#OLD_LOG_FILES=$(find "${DUMP_DIR}" -name "backup_*.log" -type f -mmin +3)
#if [ -z "$OLD_LOG_FILES" ]; then
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - No .log files older than 3 minutes found for cleanup" >> "${LOG_FILE}"
#else
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - Found .log files older than 3 minutes for cleanup" >> "${LOG_FILE}"
#  find "${DUMP_DIR}" -name "*.log" -type f -mmin +3 -exec rm -f {} \;
#  LOG_CLEANUP_STATUS=$?
#fi
#
## Log the result of the cleanup
#if [ ${SQL_CLEANUP_STATUS:-0} -eq 0 ] && [ ${LOG_CLEANUP_STATUS:-0} -eq 0 ]; then
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - Cleanup successful: Removed .sql and .log files older than 3 minutes" >> "${LOG_FILE}"
#else
#  echo "$(date +'%Y-%m-%d %H:%M:%S') - Cleanup failed!" >> "${LOG_FILE}"
#fi