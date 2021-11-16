#!/bin/sh

# Extract environment variables from Containerfile
# Separate on lines beginning with ENV on white space but not if inside quotes.
# Output string {2nd column}={3rd column} e.g. ENV EDITOR nvim > EDITOR=nvim
# Substitute " for \" in variable value (escape the " char)
ENVS=$(\
	awk 'BEGIN {FPAT = "([^ ]+)|(\"[^\"]+\")"} /^ENV/{ gsub(/"/, "\\\"", $3); print $2"="$3; }' $CONTAINERFILE \
	| sed -e 's/USER_HOME/HOME/g'\
)

# Output commands to ensure environment variables defined in ~/.profile
while IFS= read -r line
do
	setvarline="export $line"
	echo ensure_line_in_file \"$setvarline\" \~/.profile
done <<< "$ENVS"
