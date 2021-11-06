#!/bin/sh

if [ -L $0 ]
then
	DIR="$(dirname "$(readlink -f "$0")")"
else
	DIR="$(dirname "$0")"
fi

if [ "$1" == "down" ]
then
	(
		cd $(dirname $DIR)
		docker-compose down
	)
else
	CONTAINER_ID=$(
		cd $DIR
		./create_missing_host_files.sh
		cd ..
		docker-compose up --detach
		echo $(docker-compose ps --quiet --filter image=devenv)
	)

	docker attach $CONTAINER_ID
fi
