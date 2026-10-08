#!/bin/sh
# Creates the database, imports every /init/*.sql file (alphabetical order) and grants
# the application user. Idempotent: does nothing when the database already exists.
# Expects MYSQL_PWD (root password), INIT_DATABASE_HOST, INIT_DATABASE_NAME, INIT_APP_USER.

echo "[INIT DB] Waiting for $INIT_DATABASE_HOST"
until mariadb --user=root -h "$INIT_DATABASE_HOST" -e "select 1" > /dev/null 2>&1; do
  sleep 2
done

if mariadb --user=root -h "$INIT_DATABASE_HOST" -e "use \`$INIT_DATABASE_NAME\`" > /dev/null 2>&1; then
  echo "[INIT DB] Database $INIT_DATABASE_NAME already exists, nothing to do"
  exit 0
fi

set -e
# a failed import must not leave a partial database that the next run would skip
trap 'status=$?; if [ $status -ne 0 ]; then echo "[INIT DB] Failed, dropping $INIT_DATABASE_NAME"; mariadb --user=root -h "$INIT_DATABASE_HOST" -e "drop database if exists \`$INIT_DATABASE_NAME\`"; fi' EXIT

echo "[INIT DB] Creating database $INIT_DATABASE_NAME on host $INIT_DATABASE_HOST for app user $INIT_APP_USER"
mariadb --user=root -h "$INIT_DATABASE_HOST" -e "create database \`$INIT_DATABASE_NAME\`"

for filename in /init/*.sql; do
  echo "[INIT DB] process file $filename"
  mariadb --user=root -h "$INIT_DATABASE_HOST" -D "$INIT_DATABASE_NAME" < "$filename"
done

echo "[INIT DB] Grant all privileges on $INIT_DATABASE_NAME.* TO '$INIT_APP_USER'@'%'"
mariadb --user=root -h "$INIT_DATABASE_HOST" -e "GRANT ALL PRIVILEGES ON \`$INIT_DATABASE_NAME\`.* TO '$INIT_APP_USER'@'%'"
