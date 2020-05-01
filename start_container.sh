#!/bin/sh

if [ -L $0 ]
then
	DIR="$(dirname "$(readlink -f "$0")")"
else
	DIR="$(dirname "$0")"
fi

(
cd $DIR
sh create_missing_host_files.sh
docker-compose run --rm devenv
)
