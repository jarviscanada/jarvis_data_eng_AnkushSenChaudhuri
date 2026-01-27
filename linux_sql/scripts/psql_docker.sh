#!/bin/bash

cmd=$1
db_username=$2
db_password=$3

container_name="jrvs-psql"
volume_name="pgdata"

# start docker if not running
sudo systemctl status docker || sudo systemctl start docker

# check if container exists
docker container inspect $container_name >/dev/null 2>&1
container_status=$?

case $cmd in

create)
  if [ $container_status -eq 0 ]; then
    echo "Container already exists"
    exit 1
  fi

  if [ $# -ne 3 ]; then
    echo "Create requires username and password"
    exit 1
  fi

  docker volume create $volume_name

  docker run --name $container_name \
    -e POSTGRES_USER=$db_username \
    -e POSTGRES_PASSWORD=$db_password \
    -d \
    -v $volume_name:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:9.6-alpine

  exit $?
  ;;

start|stop)
  if [ $container_status -ne 0 ]; then
    echo "Container does not exist"
    exit 1
  fi

  docker container $cmd $container_name
  exit $?
  ;;

*)
  echo "Illegal command"
  echo "Usage: create|start|stop"
  exit 1
  ;;
esac

