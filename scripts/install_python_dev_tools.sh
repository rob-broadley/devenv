#!/bin/sh

# Get default Python 3 minor version.
# e.g. if python3 --version returns Python 3.11.6, store 11.
python3_minor=$(python3 --version | cut --delimiter . --fields 2)
printf "Default Python is python3.%s\n" $python3_minor

# Generate list of installs including recent Python versions and tools for development.
# Where Python versions other than the default are needed, it is expected that one of
# the following will be used tox, venv (python3.x -m venv),
# or python3.x -m pip install --user {package}.
installs=$(
	echo python3{9,10,11,12,$python3_minor{,-tox,-invoke,-jupyter}} \
	| tr ' ' '\n' | sort -u | tr '\n' ' '
)
printf "Installing: %s\n" "$installs"

# Install the packages.
sudo zypper install --no-confirm $installs
