#!/bin/sh

# Interactive setup script for global git configuration.
# Configures user identity, optional GPG commit signing, and git preferences.
# Prerequisites: git; gpg (gnupg2) if enabling commit signing.

printf 'Enter name (First_name Last_Name): ' >&2
read -r name
git config --global user.name "$name"

printf 'Enter email address: ' >&2
read -r email
git config --global user.email "$email"

printf 'Do you want to sign commits (y/n)? ' >&2
read -r sign
if [ "$sign" = "y" ]
then
	printf 'Generate key (y/n)? ' >&2
	read -r generate
	if [ "$generate" = "y" ]
	then
		uid="$name (Git) <$email>"
		gpg --quick-generate-key "$uid" default default none
		fpr=$(gpg --list-options show-only-fpr-mbox --list-keys "$uid" | awk '{print $1}')
		if [ -z "$fpr" ]; then
			printf 'Failed to extract GPG key fingerprint.\n' >&2
			exit 1
		fi
		printf '%s\n' "Generated key with fingerprint: $fpr"
		gpg --quick-add-key "$fpr" default sign
		# BEGIN { FS=":" } is required: FS set in the action block applies only from
		# the second record onward, so the first record would be split on whitespace.
		key=$(\
			gpg --list-secret-keys --with-colons "$uid" \
			| awk 'BEGIN { FS=":" } $1 == "ssb" && $2 == "u" && $12 == "s" { print $5 }' \
			| head -n 1\
		)
		if [ -z "$key" ]; then
			printf 'Failed to extract GPG signing subkey ID.\n' >&2
			exit 1
		fi
		printf '%s\n' "Generated signing subkey with ID: $key"
	else
		printf "\nAvailable Keys:\n===============\n"
		gpg --keyid-format LONG --list-secret-keys
		printf 'Enter signing key: ' >&2
		read -r key
	fi
	git config --global user.signingKey "$key"
	git config --global commit.gpgSign true
	git config --global tag.gpgSign true
fi

git config --global blame.coloring highlightRecent
git config --global diff.colorMoved zebra
git config --global diff.tool nvimdiff
git config --global fetch.prune true
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
git --no-pager config --global --list


if [ "$sign" = "y" ]
then
	printf "\n\nYour Public GPG Key"
	printf "\n===================\n"
	gpg --export --armour "$key"
fi
