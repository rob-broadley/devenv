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

	# Make user default.
	# echo [user] >> /etc/wsl.conf
	# echo default=$user >> /etc/wsl.conf
fi

# Enable services.
systemctl enable docker

# Upgrade OS.
echo  # Line break.
read -p 'Upgrade OS? [Y/n]: ' upgrade
echo  # Line break.
case $upgrade in
	[Nn]*)
		echo 'Skipping OS upgrade...'
		;;
	*)
		echo 'Upgrading OS...'
		zypper dist-upgrade
		;;
esac
