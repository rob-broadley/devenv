#!/bin/sh

# Add repository and install code package.
# Install DejaVu fonts and Nerd font symbols.
sudo --shell -- <<EOF
rpm --import https://packages.microsoft.com/keys/microsoft.asc
zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
zypper refresh
zypper install --no-confirm code dejavu-fonts symbols-only-nerd-fonts
EOF

# Install extensions:
# - One Dark Theme
code \
	--install-extension zhuangtongfa.material-theme

# Configure VSCode for calling user.
printf "Configuring VSCode...\n"
VSCODE_SETTINGS_FILE="${HOME}/.config/Code/User/settings.json"
# Read VSCode settings (stdout of cat) into var, ignoring any errors (stderr).
settings_json=$(cat $VSCODE_SETTINGS_FILE 2> /dev/null)

# If VSCode settings empty or does not exist, create with desired settings.
# If not empty, update values for settings of interest.
if [ -z "$settings_json" ]
then
	settings_json="{}"
fi
new_settings=$(
	echo $settings_json \
	| jq \
	--tab \
	--sort-keys \
	--arg titlebarstyle custom \
	--arg fontfamily "'Symbols Nerd Font', 'DejaVu Sans Mono', 'monospace', monospace" \
	--arg fontsize 12 \
	--arg theme "One Dark Pro" \
	'."window.titleBarStyle"|=$titlebarstyle
	 | ."editor.fontFamily"|=$fontfamily
	 | ."editor.fontSize"|=($fontsize|tonumber)
	 | ."terminal.integrated.fontSize"|=($fontsize|tonumber)
	 | ."workbench.colorTheme"|=$theme
	'
)
# If settings modified successfully write to file, else exit with error.
return_code=$?
if [ $return_code -eq 0 ]
then
	mkdir --parents $(dirname $VSCODE_SETTINGS_FILE)
	echo "$new_settings" > $VSCODE_SETTINGS_FILE
else
	printf "\033[31mERROR\033[0m\n"
	exit $return_code
fi

printf "Adding alias which enables wayland support...\n"
CODE_ALIAS="/usr/local/bin/code"
cat << 'EOF' | sudo tee $CODE_ALIAS > /dev/null
#!/bin/sh

# Get directory containing current script and temporarily remove it from PATH.
this_script_dir="$(dirname "$0")"
PATH=$(echo "$PATH" | sed -e "s|$this_script_dir:||")
# Run the real code bin with args given.
code --ozone-platform-hint=auto $@ 2> /dev/null
EOF
sudo chmod +x $CODE_ALIAS

printf "Adding VSCode to the application launcher...\n"
distrobox-export --app code --extra-flags "--ozone-platform-hint=auto"

printf "Done!\n"
