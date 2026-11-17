#!/usr/bin/env bash
# Part 4 - run Tomcat (our image), Nginx and PostgreSQL as containers on one network.
# Usage (from the repo root):  bash docker/run-containers.sh [image]
#   image defaults to ps-tomcat:1.0 (local build); pass <dockerhub-user>/ps-tomcat:1.0 to use the pushed one.
set -euo pipefail
IMAGE="${1:-ps-tomcat:1.0}"
cd "$(dirname "$0")"

# A user-defined bridge network gives containers DNS by container name.
docker network inspect ps-net >/dev/null 2>&1 || docker network create ps-net

docker rm -f ps-tomcat ps-nginx ps-postgres >/dev/null 2>&1 || true

# Tomcat with the sample WAR
docker run -d --name ps-tomcat --network ps-net -p 127.0.0.1:8080:8080 "$IMAGE"

# Nginx, config mounted read-only, published on host port 8088
docker run -d --name ps-nginx --network ps-net -p 127.0.0.1:8088:80 \
  -v "$PWD/nginx.conf:/etc/nginx/conf.d/default.conf:ro" nginx:1.27-alpine

# PostgreSQL 16 with a named volume so data survives container removal
docker run -d --name ps-postgres --network ps-net -p 127.0.0.1:5432:5432 \
  -e POSTGRES_USER=ps -e POSTGRES_PASSWORD="${PG_PASSWORD:-ps_pg_2026}" -e POSTGRES_DB=psdb \
  -v ps-pgdata:/var/lib/postgresql/data postgres:16-alpine

docker ps --filter network=ps-net --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
