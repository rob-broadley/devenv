#!/bin/sh

default_uid="{{ uid }}"

# Create user account if one does not exist.
if getent passwd "$default_uid" > /dev/null ; then
  echo 'A user account already exists, skipping creation'
else
	# Create user account.
	echo 'Creating user account... '
	printf '    Enter username: ' >&2
	read -r user
	useradd \
		--create-home \
		--groups wheel,docker \
		--shell /bin/zsh \
		--uid "$default_uid" \
		"$user"
fi

# Enable services.
echo  # Line break.
echo 'Enabling System Services:'
echo  # Line break.
echo 'Shared Root'
systemctl enable shared-root
echo 'Docker'
systemctl enable docker

echo  # Line break.
echo 'Setting up Podman...'
# Set up UIDs for rootless Podman.
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$user"

# Upgrade OS.
echo  # Line break.
printf 'Upgrade OS? [Y/n]: ' >&2
read -r upgrade
echo  # Line break.
case $upgrade in
	[Nn]*)
		echo 'Skipping OS upgrade.'
		;;
	*)
		echo 'Upgrading OS...'
		zypper dist-upgrade
		;;
esac
