#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: ./host_info.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
hostname=$(hostname -f)
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# Hardware info
cpu_number=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
cpu_architecture=$(lscpu | awk '/^Architecture:/ {print $2}')
cpu_model=$(lscpu | awk -F: '/^Model name:/ {print $2}' | xargs | sed "s/'/''/g")  # escape single quotes
cpu_mhz=$(lscpu | awk '/^CPU MHz:/ {print $3}')
l2_cache=$(lscpu | awk -F: '/^L2 cache:/ {gsub("K","",$2); print $2}' | xargs)   # remove K
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2/1024}')  # MB, numeric only

# Build INSERT statement
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) 
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp');"

# Run INSERT
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?

