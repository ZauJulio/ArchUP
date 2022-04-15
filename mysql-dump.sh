#!/bin/sh
mkdir -p data/mysql

HOST="172.17.0.3"
PORT="3306"
USER="root"
DB="local"

mysqldump -u $USER -p --host=$HOST --port=$PORT $DB > ./data/mysql/$DB.sql