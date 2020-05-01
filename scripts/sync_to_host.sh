#!/bin/sh

SRC="$1"
DEST="$HOSTHOME/$(hostname)$(realpath $1)"

if [ -d $SRC ] && [ "${SRC: -1}" != "." ]
then
	DEST="$(dirname $DEST)"
fi


mkdir --parents $DEST
rsync --archive $SRC $DEST
