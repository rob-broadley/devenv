#!/bin/sh

# Show the default Python 3 version.
printf "Default Python is: %s\n" "$(python3 --version)"

# Generate list of installs including recent Python versions and tools for development.
# Where Python versions other than the default are needed, it is expected that one of
# the following will be used tox, venv (python3.x -m venv),
# or python3.x -m pip install --user {package}.
installs=$(xargs <<ENDLIST
python39
python310
python311
python312
python313
python3-invoke
python3-jupyter
python3-tox
ENDLIST
)
printf "Installing: %s\n" "$installs"

# Install the packages.
# shellcheck disable=SC2086
# Word splitting is required here.
sudo zypper install --no-confirm $installs

# Set up invoke auto-completion.
sudo mkdir -p "$ZSH_SITE_CONFIG_DIR"
invoke --print-completion-script=zsh \
	| sudo tee "$ZSH_SITE_CONFIG_DIR/_complete_invoke.zsh" \
	> /dev/null
