#!/bin/sh

handle_status_code () {
	code=$1
	output="${@:2}"
	case $code in
		0)
			printf >&2 "\033[32m [ OK ]\n\033[0m"
			;;
		*)
			printf >&2 "\033[31m [FAIL]\n\033[0m\n" " "
			printf >&2 "\033[31m%s\033[0m\n" "${output}"
			exit $code
			;;
	esac
}


printf "Performing initialisation...\n"

printf "%-40s\t" "Set file permissions..."
# This is only needed because when distrobox creates users home from /etc/skel
# directories are owned by root.
output="$(sudo chown -R $(id --user):$(id --group) $HOME 2>&1)"
handle_status_code $? "$output"

printf "%-40s\t" "Refresh repositories..."
output="$(sudo zypper refresh 2>&1)"
handle_status_code $? "$output"

printf "%-40s\t" "Update installed packages..."
output=$(sudo zypper dist-upgrade --no-confirm 2>&1)
handle_status_code $? "$output"

# Install Nvim and Coc Plugins (By running vim lazy.nvim will do installs).
printf "%-40s\t" "Setting up neovim..."
output=$(nvim --headless -c ":CocInstall -sync coc-json" +qa 2>&1)
handle_status_code $? "$output"

# Set up app passthrough.
printf "%-40s\t" "Setting up application passthroughs..."
output=$(
	zsh -c '
		declare -i RESULT=0
		autoload -Uz app-passthrough
		RESULT+=$?
		app-passthrough --force xdg-open
		RESULT+=$?
		app-passthrough --force podman
		RESULT+=$?
		app-passthrough --force distrobox
		RESULT+=$?
		exit $RESULT
	' \
	2>&1
)
handle_status_code $? "$output"

printf "\n\033[32m%s\033[0m\n\n" "Success"
