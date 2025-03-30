
FROM mysql:8.0-debian

# Install cron and any necessary utilities
RUN apt-get update && apt-get install -y cron bash && rm -rf /var/lib/apt/lists/*
#doc# Set environment variables (you can override these later with Docker run if needed)
#ENV DB_HOST=your_db_host
#ENV DB_PORT=3306
#ENV DB_USER=your_db_user
#ENV DB_PASS=your_db_password
#ENV DB_NAME=mmt

# Set working directory
WORKDIR /app

# Copy the shell script into the container
COPY dump_tablesCron.sh /app/dump_tablesCron.sh

# Copy the MySQL credentials file into the container
COPY .my.cnf /root/.my.cnf

# Set the script as executable
RUN chmod +x /app/dump_tablesCron.sh

# Set timezone to India
RUN ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo "Asia/Kolkata" > /etc/timezone
# Add cron job to run the backup script every minute
RUN echo "0 9 * * * /bin/bash /app/dump_tablesCron.sh >> /app/backup.log 2>&1" > /etc/cron.d/mysql-backup
# Set permissions for the cron file
RUN chmod 0644 /etc/cron.d/mysql-backup

# Apply the cron job
RUN crontab /etc/cron.d/mysql-backup

# Create a directory for storing dumps (if necessary)
RUN mkdir -p /app/dumps

# Start cron in the foreground when the container runs
CMD echo "Backup service is started now" >> /app/dumps/backup_$(date +'%Y-%m-%d').log && cron -f