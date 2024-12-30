#!/bin/sh

# Create user account if one does not exist.
if getent passwd {{ uid }} > /dev/null ; then
  echo 'A user account already exists, skipping creation'
else
	# Create user account.
	echo 'Creating user account... '
	read -p '    Enter username: ' user
	useradd \
		--create-home \
		--groups wheel,docker \
		--shell /bin/zsh \
		--uid {{ uid }} \
		$user
fi

# Enable services.
echo  # Line break.
echo 'Enabling System Services:'
echo  # Line break.
echo 'Docker'
systemctl enable docker

echo  # Line break.
echo 'Setting up Podman...'
# Set up UIDs for rootless Podman.
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $user

# Upgrade OS.
echo  # Line break.
read -p 'Upgrade OS? [Y/n]: ' upgrade
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
