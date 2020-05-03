#!/bin/sh

# Set defaults
DISTRO=${DISTRO:-fedora}
PKG_INSTALL=${PKG_INSTALL:-"sudo dnf install -y"}

# Get parent of directory which contains this script
if [ -L $0 ]
then
	DIR="$(dirname "$(readlink -f "$0")")"
else
	DIR="$(dirname "$0")"
fi
DIR="$(dirname "$DIR")"

# Set file locations
OUTPUT="$DIR/install.sh"
REQUIREMENTS="$DIR/requirements.txt"
CONTAINERFILE="$DIR/Containerfile"


cat > $OUTPUT << EOF
#!/bin/sh

ensure_line_in_file () {
	grep -qF "\$1" "\$2" || ( echo "\$1" >> "\$2" && return 10 )
}

copy () {
	src="\$1"
	dest="\$2"
	if [ -f "\$src" ]; then
		cp --interactive --backup=numbered "\$src" "\$dest"
	elif [ -d "\$src" ]; then
		src="\$src/."
		if [ -e "\$dest" ]; then
			echo "\n\$dest exists."
			read -n 3 -p "Enter 1 to replace all, 2 for update, 3 for interactive update or anything else to skip: " user_response
			if [ "\$user_response" == "1" ]; then
				cp -Rf "\$src" "\$dest"
			elif [ "\$user_response" == "2" ]; then
				cp -R --update "\$src" "\$dest"
			elif [ "\$user_response" == "3" ]; then
				cp -R --update --interactive "\$src" "\$dest"
			fi
		else
			mkdir -p "\$dest"
			cp -R "\$src" "\$dest"
		fi
	fi
}

# Install required packages
$PKG_INSTALL $(grep -v '^#' $REQUIREMENTS | tr "\n" " ")

# Add environment variable to ~.profile
ensure_line_in_file "export DISTRO=$DISTRO" ~/.profile
EOF

# Extract environment variables from Containerfile
ENVS=$(\
	awk '/^ENV/{ if ($2 != "DISTRO") print $2"="$3; }' $CONTAINERFILE \
	| sed -e 's/USER_HOME/HOME/g'\
)

{
# Add commands to ensure environment variables defined in ~/.profile
for ENV in $ENVS
do
	# Set var locally
	echo $ENV
	# Make var persistent
	setvarline="export $(sed 's/\$/\\$/g' <<< $ENV)"
	echo ensure_line_in_file \"$setvarline\" \~/.profile
done

# Add blank line
echo

# Extract copy commands from Containerfile
echo \# Copy required files
awk '/^WORKDIR/{flag=1;next}/^COPY/{ if(flag) print "copy", $2, "~/"$3; }' $CONTAINERFILE

# Add blank line
echo

echo \# Local setup commands
} >> $OUTPUT


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
