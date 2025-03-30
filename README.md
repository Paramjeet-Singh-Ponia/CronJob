# CronJob
Automated Cron Job for Database Backup &amp; Space Management

# MySQL Dump Automation with Docker

## Overview
This project automates MySQL table dumps using a Docker container. A cron job is set up to run daily at 1:00 AM, dumping selected tables into `.sql` files.

### Files
1. **Dockerfile**: Defines the Docker image with `mysql-client` and a cron job.
2. **scripts/dump_tables.sh**: Shell script to dump specific MySQL tables.
3. **README.md**: Documentation for the project.

### Setup

1. Clone the repository and navigate to the project root.
2. Add your database credentials and table names in `scripts/dump_tables.sh`.
3. Build the Docker image:
   ```bash
   docker build -t mysql-dump-cron .
