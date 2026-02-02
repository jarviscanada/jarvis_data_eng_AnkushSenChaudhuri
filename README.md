# Linux Monitoring Agent

## Introduction

This project implements a Linux Monitoring Agent that collects and stores hardware specifications and real-time resource usage data from Linux hosts. The purpose of the system is to help the LCA (Linux Cluster Administration) team understand host capacity, performance trends, and system health across multiple machines.

The solution uses lightweight Bash scripts running on each Linux host to gather CPU, memory, and disk metrics. The collected data is centralized in a PostgreSQL database running inside a Docker container. System usage data is captured automatically every minute using crontab, enabling continuous monitoring without manual intervention.

The primary users of this project are system administrators and infrastructure managers who require visibility into host-level metrics for capacity planning and troubleshooting. Technologies used include Bash scripting, Docker, PostgreSQL, Git/GitHub, SQL, and Linux utilities.

---

## Quick Start

### 1. Start PostgreSQL using Docker

```bash
./scripts/psql_docker.sh start
```

### 2. Create database tables

```bash
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```

### 3. Insert hardware specifications

```bash
./scripts/host_info.sh localhost 5432 host_agent postgres password
```

### 4. Insert host usage data

```bash
./scripts/host_usage.sh localhost 5432 host_agent postgres password
```

### 5. Crontab setup (run every minute)

```bash
* * * * * /home/rocky/dev/jarvis_data_eng_AnkushSenChaudhuri/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password
```

---

## Implementation

### Architecture

The system consists of multiple Linux hosts connected to a centralized PostgreSQL database.

* Each Linux host runs a monitoring agent
* Agents collect system metrics using Linux commands
* Data is inserted into a PostgreSQL database
* Crontab automates data collection every minute

---

### Scripts

#### psql_docker.sh

Starts or stops a PostgreSQL Docker container.

```bash
./psql_docker.sh start|stop
```

Used to provide a consistent database environment for development.

---

#### host_info.sh

Collects static hardware information and inserts it into the database.

Collected metrics include:

* Hostname
* CPU count
* CPU architecture
* CPU model
* CPU frequency
* L2 cache size
* Total memory

```bash
./host_info.sh <psql_host> <psql_port> <db_name> <user> <password>
```

This script runs once per host.

---

#### host_usage.sh

Collects dynamic system usage metrics.

Metrics collected:

* Free memory
* CPU idle percentage
* CPU kernel usage
* Disk I/O
* Available disk space

```bash
./host_usage.sh <psql_host> <psql_port> <db_name> <user> <password>
```

This script is designed to run every minute via crontab.

---

#### Crontab

Automates execution of host_usage.sh every minute:

```bash
* * * * * /path/to/host_usage.sh localhost 5432 host_agent postgres password
```

---

#### queries.sql

Contains analytical SQL queries to support business decisions, such as:

* Identifying hosts with low available memory
* Monitoring CPU utilization trends
* Comparing resource usage across hosts
* Supporting capacity planning and scaling decisions

---

## Database Modeling

### host_info

| Column           | Description              |
| ---------------- | ------------------------ |
| id               | Unique host identifier   |
| hostname         | Fully qualified hostname |
| cpu_number       | Number of CPUs           |
| cpu_architecture | CPU architecture type    |
| cpu_model        | CPU model name           |
| cpu_mhz          | CPU clock speed          |
| l2_cache         | L2 cache size            |
| total_mem        | Total system memory (MB) |
| timestamp        | Record creation time     |

---

### host_usage

| Column         | Description                       |
| -------------- | --------------------------------- |
| timestamp      | Data collection time              |
| host_id        | Foreign key referencing host_info |
| memory_free    | Free memory (MB)                  |
| cpu_idle       | CPU idle percentage               |
| cpu_kernel     | CPU kernel usage                  |
| disk_io        | Disk I/O operations               |
| disk_available | Available disk space (MB)         |

---

## Test

The project was tested manually through the following steps:

* Verified Docker container creation using `docker ps`
* Executed ddl.sql and confirmed table creation
* Ran host_info.sh and validated row insertion
* Executed host_usage.sh multiple times and confirmed increasing row counts
* Tested crontab by observing automatic inserts every minute

All scripts executed successfully with valid outputs in the database.

---

## Deployment

The application was deployed using:

* **GitHub** for source control and version management
* **Docker** for PostgreSQL database deployment
* **Crontab** for automated metric collection
* **Linux Bash scripts** for monitoring agents

The system can be easily deployed on additional Linux hosts by cloning the repository and configuring crontab.

---

## Improvements

Future enhancements could include:

1. Automatically updating host_info when hardware changes occur
2. Adding alerting for CPU or memory threshold breaches
3. Creating a dashboard using Grafana or Power BI
4. Supporting multiple database environments
5. Improving error handling and logging mechanisms

---

## Author

**Ankush Sen Chaudhuri**
Business Analyst
