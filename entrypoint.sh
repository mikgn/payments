#!/bin/bash
set -e

rm -f /app/tmp/pids/server.pid

bin/docker_setup

exec "$@"
