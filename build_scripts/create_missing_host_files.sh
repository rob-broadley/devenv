#!/bin/sh

#FILES=(\
#)

DIRECTORIES=(\
	$HOME/.gnupg \
	$HOME/.ssh \
	$HOME/.config/git \
	$HOME/projects \
	$HOME/repos \
)


#for FILE in ${FILES[*]}
#do
#	[ -f "$FILE" ] || touch $FILE
#done


for DIR in ${DIRECTORIES[*]}
do
	[ -d "$DIR" ] || mkdir $DIR
done
