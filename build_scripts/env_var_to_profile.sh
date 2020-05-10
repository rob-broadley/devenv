#!/bin/sh

# Extract environment variables from Containerfile
ENVS=$(\
	awk '/^ENV/{ print $2"="$3; }' $CONTAINERFILE \
	| sed -e 's/USER_HOME/HOME/g'\
)

# Add commands to ensure environment variables defined in ~/.profile
for ENV in $ENVS
do
	setvarline="export $ENV"
	echo ensure_line_in_file \"$setvarline\" \~/.profile
done
