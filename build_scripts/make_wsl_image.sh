#!/bin/sh

BUILDSCRIPTS="$(realpath $(dirname "$0"))"
REPO="$(dirname "$BUILDSCRIPTS")"
FUNC="$BUILDSCRIPTS/functions"

# Set file locations
CONTAINERFILE="$REPO/Containerfile"

LOCAL="$BUILDSCRIPTS/tmp.sh"
INTERNAL="/tmp/setup.sh"


printf %"s\n\n" "#!/bin/sh" > $LOCAL
cat "$FUNC/ensure_line_in_file.sh" >> $LOCAL
printf %"s\n\n" "touch ~/.profile" >> $LOCAL

source "$BUILDSCRIPTS/env_var_to_profile.sh" >> $LOCAL
chmod +x $LOCAL

CONTAINER=$(\
	docker run -i --detach --entrypoint=sh \
	--mount type=bind,source="$LOCAL",destination="$INTERNAL" \
	devenv\
)
docker exec $CONTAINER sh $INTERNAL
docker export $CONTAINER > devenv.tar
docker stop $CONTAINER > /dev/null
docker rm $CONTAINER > /dev/null

rm $LOCAL
