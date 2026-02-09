#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
if [ "$#" -ne 5 ]; then
echo "Illegal number of parameters"
echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
exit 1
fi
# ---------------------------
# Collect usage metrics
# ---------------------------
hostname=$(hostname -f)
timestamp=$(date -u '+%F %T')
vmstat_out=$(vmstat --unit M | tail -1)
# vmstat columns (typical):
# r b swpd free buff cache si so bi bo in cs us sy id wa st
memory_free=$(echo "$vmstat_out" | awk '{print $4}' | xargs) # MB
cpu_kernel=$(echo "$vmstat_out" | awk '{print $14}' | xargs) # sy (%)
cpu_idle=$(echo "$vmstat_out" | awk '{print $15}' | xargs) # id (%)
# disk_io: reads/writes in progress (vmstat -d last field "inprog")
disk_io=$(vmstat -d | tail -1 | awk '{print $NF}' | xargs)
# disk_available in MB from root filesystem
disk_available=$(df -BM / | tail -1 | awk '{gsub(/M/,"",$4); print $4}' | xargs)
# Subquery to find host id
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"
# ---------------------------
# Insert into DB
# ---------------------------
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle,
cpu_kernel, disk_io, disk_available)
VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io,
$disk_available);"
export PGPASSWORD="$psql_password"
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit_code=$?
unset PGPASSWORD
