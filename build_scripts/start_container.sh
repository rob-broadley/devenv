#!/bin/sh

if [ -L $0 ]
then
	DIR="$(dirname "$(readlink -f "$0")")"
else
	DIR="$(dirname "$0")"
fi

if [ -z $1 ]
then
	EXTRA_ARGS=""
else
	EXTRA_ARGS="--workdir=$(realpath $1)"
fi

(
cd $DIR
./create_missing_host_files.sh
cd ..
docker-compose run --rm $EXTRA_ARGS devenv
)
