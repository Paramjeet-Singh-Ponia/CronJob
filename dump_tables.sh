#!/bin/bash

# to fetch tables dump directly into the local by .sh file
DB_NAME="mmt"
CREDENTIAL_PATH="../mysql_Dump/.my.cnf"

# Tables to be dumped (space-separated)
TABLES=("cg_automation_new" "cg_automation_new_booking" "hotel_affilaitegateway" "hotel_affilaitegateway_dummy" "hotel_new_web_api" "hotel_web_api_booking_new" "da_automation")  # Replace with your table names

# Dump location
DUMP_DIR="../mysql_Dump/dumps"
DATE=$(date +'%Y-%m-%d')

# Create dump directory if it doesn't exist
mkdir -p "${DUMP_DIR}"

# Iterate over each table and dump data
for TABLE in "${TABLES[@]}"; do
  DUMP_FILE="${DUMP_DIR}/${TABLE}_${DATE}.sql"

  # Dump the table
mysqldump --defaults-file="${CREDENTIAL_PATH}" --no-tablespaces "${DB_NAME}" "${TABLE}" > "${DUMP_FILE}"
  if [ $? -eq 0 ]; then
    echo "Backup successful for table '${TABLE}': ${DUMP_FILE}"
  else
    echo "Backup failed for table '${TABLE}'!" >&2
  fi
done
