#!/bin/sh

# Set defaults
PKG_INSTALL=${PKG_INSTALL:-"sudo zypper install --no-confirm"}

# Get parent of directory which contains this script
if [ -L $0 ]
then
	BUILDSCRIPTS="$(dirname "$(readlink -f "$0")")"
else
	BUILDSCRIPTS="$(dirname "$0")"
fi
REPO="$(dirname "$BUILDSCRIPTS")"
FUNC="$BUILDSCRIPTS/functions"

# Set file locations
OUTPUT="$REPO/install.sh"
REQUIREMENTS="$REPO/requirements.txt"
CONTAINERFILE="$REPO/Containerfile"


insert () {
	printf %"s\n" "$1" >> $OUTPUT
}


# Add hash bang
printf %"s\n" "#!/bin/sh" "" > $OUTPUT

# Add functions
cat "$FUNC/ensure_line_in_file.sh" >> $OUTPUT
insert "" ""
cat "$FUNC/copy.sh" >> $OUTPUT
insert ""

# Add command to install required packages
cat >> $OUTPUT << EOF
# Install required packages
$PKG_INSTALL $(grep -v '^#' $REQUIREMENTS | tr "\n" " ")

EOF

# Ensure environment variables are set in .profile
insert "# Add environment variables to ~.profile"
source "$BUILDSCRIPTS/env_var_to_profile.sh" >> $OUTPUT
insert "source ~/.profile"

insert ""

{
	printf %"s\n" "# Copy required files"
	awk '/^WORKDIR/{flag=1;next}/^COPY/{ if(flag) print "copy", $2, "~/"$3; }' $CONTAINERFILE
} >> $OUTPUT

insert ""

insert "# Local setup commands"

# Extract commands in local setup block
# (between ### BEGIN local_setup and END local_setup)
LOCAL_SETUP=$(\
	awk \
	'/^### BEGIN local_setup/{ flag=1; next }/^### END local_setup/{ flag=0; next }/^RUN/{ if(flag) {for (i=2; i<NF; i++) printf $i " "; print $NF} }' \
	"$CONTAINERFILE"\
)
# Set soft-link creation to interactive (ls -si)
LOCAL_SETUP=$(sed -r "s/ln -sf? /ln -si /" <<< "$LOCAL_SETUP")
cat <<< "$LOCAL_SETUP" >> $OUTPUT

chmod +x $OUTPUT
