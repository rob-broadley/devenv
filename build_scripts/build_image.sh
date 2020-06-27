#!/bin/sh

HOST_DOCKER_GID=$(getent group docker | awk -F ":" '{ print $3 }')

(export HOST_DOCKER_GID && docker-compose build devenv)
