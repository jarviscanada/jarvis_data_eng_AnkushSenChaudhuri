#!/bin/bash

#Setting up arguments
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

hostname=$(hostname -f)
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | sed -n 's/^Model name:[[:space:]]*//p' | xargs)
# Some VMs don't expose MHz via lscpu; /proc/cpuinfo is usually more reliable
cpu_mhz=$(awk -F': ' '/^cpu MHz/{print $2; exit}' /proc/cpuinfo | xargs)
l2_cache=$(echo "$lscpu_out" | awk -F: '/^L2 cache:/{print $2}' | grep -oE '[0-9]+' | head -1)
total_mem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo | xargs) # kB
timestamp=$(date -u '+%F %T')

# Insert into database host_agent
# (If your table has UNIQUE(hostname), ON CONFLICT prevents duplicates.
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model,
cpu_mhz, L2_cache, total_mem, timestamp)
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache,
$total_mem, '$timestamp')
ON CONFLICT (hostname) DO NOTHING;"
export PGPASSWORD="$psql_password"
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit_code=$?
unset PGPASSWORD
exit $exit_code
