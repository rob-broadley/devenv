#!/bin/sh

read -p "Enter name (First_name Last_Name): " name
git config --global user.name "$name"

read -p "Enter email address: " email
git config --global user.email "$email"

read -p "Do you want to sign commits (y/n)? " sign
if [ $sign = "y" ]
then
	read -p "Generate key (y/n)? " generate
	if [ $generate = "y" ]
	then
		gpg --quick-gen-key "$name (Git GPG key) <$email>" default default none
	fi
	printf "\nAvailable Keys:\n===============\n"
	gpg --list-keys
	read -p "Enter signing key: " key
	git config --global user.signingkey "$key"
	git config --global commit.gpgsign true
fi

git config --global blame.coloring highlightRecent
git config --global diff.colorMoved zebra
git config --global diff.tool nvimdiff
git config --global merge.log true
git config --global merge.tool nvimdiff
git config --global pull.rebase true
git config --global rebase.autosquash true


printf "\nYour global git configuration"
printf "\n=============================\n"
git config --global --list
