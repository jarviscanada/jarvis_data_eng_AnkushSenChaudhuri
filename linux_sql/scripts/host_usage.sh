#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

hostname=$(hostname -f)
timestamp=$(date -u '+%F %T')

vmstat_out=$(vmstat --unit M | tail -1)

memory_free=$(echo "$vmstat_out" | awk '{print $4}' | xargs)
cpu_kernel=$(echo "$vmstat_out" | awk '{print $14}' | xargs)
cpu_idle=$(echo "$vmstat_out" | awk '{print $15}' | xargs)

disk_io=$(vmstat -d | tail -1 | awk '{print $NF}' | xargs)

disk_available=$(df -BM / | tail -1 | awk '{gsub(/M/,"",$4); print $4}' | xargs)

host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

insert_stmt="
INSERT INTO host_usage (
  timestamp,
  host_id,
  memory_free,
  cpu_idle,
  cpu_kernel,
  disk_io,
  disk_available
)
VALUES (
  '$timestamp',
  $host_id,
  $memory_free,
  $cpu_idle,
  $cpu_kernel,
  $disk_io,
  $disk_available
);
"

export PGPASSWORD="$psql_password"

psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -c "$insert_stmt"

exit $?

