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
git config --global init.defaultBranch main
git config --global log.date auto:relative
git config --global merge.log true
git config --global merge.tool nvimdiff
git config --global pull.rebase true
git config --global rebase.autoSquash true
git config --global rebase.autoStash true

# Aliases
git config --global alias.aliases "config --get-regexp '^alias\\.'"
git config --global alias.amend "commit --amend"
git config --global alias.fix "commit --fixup"
git config --global alias.pushf "push --force-with-lease"
git config --global alias.rebase-keep-date "rebase --interactive --committer-date-is-author-date"
git config --global alias.rebase-keep-merge "rebase --interactive --rebase-merges"
git config --global alias.tree "log --graph --all --oneline"
git config --global alias.tree-detailed "log --graph --all"


printf "\nYour global git configuration"
printf "\n=============================\n"
git config --global --list
