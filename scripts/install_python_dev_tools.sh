#!/bin/sh

# Generate list of installs for recent Python versions.
# Where Python versions other than the default are needed,
# it is expected that one of the following will be used
# tox, venv (python3.x -m venv),
# or python3.x -m pip install --user {package}.
installs=$(xargs <<ENDLIST
python3
python3-devel
python39
python310
python311
python312
python313
uv
ENDLIST
)
printf "Installing: %s\n" "$installs"

# Install the packages.
# shellcheck disable=SC2086
# Word splitting is required here.
sudo zypper install --no-confirm $installs

# Show the default Python 3 version.
printf "Default Python is: %s\n" "$(python3 --version)"

# Point python to python3.
sudo ln --symbolic --force "$(which python3)" /usr/local/bin/python

# Install tools.
uv tool install black
uv tool install invoke
uv tool install ipython
uv tool install jupyterlab
uv tool install mypy
uv tool install pylint
uv tool install ruff
uv tool install --with tox-uv tox

# Set up invoke auto-completion.
mkdir -p "$ZSH_USER_CONFIG_DIR"
# Make sure there is a zshrc file in the directory,
# otherwise zsh shows a message on initialisation.
touch "$ZSH_USER_CONFIG_DIR/.zshrc"
# Write completion script to a location where it will
# be sourced on zsh initialisation.
invoke --print-completion-script=zsh \
	> "$ZSH_USER_CONFIG_DIR/_complete_invoke.zsh"

# Set up ruff auto-completion.
mkdir -p "$ZSH_USER_COMPLETIONS_DIR"
ruff generate-shell-completion zsh \
	> "$ZSH_USER_COMPLETIONS_DIR/_ruff"
