#!/bin/sh

ensure_line_in_file () {
	grep -qF "$1" "$2" || ( echo "$1" >> "$2" && return 10 )
}

PROFILE_FILE="{{ profile_file }}"
touch "$PROFILE_FILE"

# Install WSL compatability packages.
wsl_conf=/etc/wsl.conf
zypper install --no-recommends --no-confirm \
	aaa_base-wsl \
	patterns-wsl-base \
	patterns-wsl-systemd \
	patterns-wsl-gui
rm $wsl_conf  # The wsl patterns make it a symlink.

cat > $wsl_conf <<EOF
[boot]
systemd=true

EOF

# Install password-store (pass), required by rancher/docker desktop.
# Devcontainer builds fail to pull images without this.
zypper install --no-recommends --no-confirm password-store

# Install container based development tools.
zypper install --no-recommends --no-confirm distrobox podman

# Clean up zypper caches to reduce image size.
zypper --non-interactive clean --all
rm --recursive --force /var/log/zypp /var/log/zypper.log

# Give password-less sudo. This is only acceptable as it is a private
# development environment not exposed to the outside world.
# Do NOT do this on your host machine or otherwise.
echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Make neovim load WSL specific config.
ensure_line_in_file "lua require('wsl')" '/etc/xdg/nvim/sysinit.vim'

# Hide podman cgroups-v1 deprecation warning.
ensure_line_in_file 'export PODMAN_IGNORE_CGROUPSV1_WARNING=true' "$PROFILE_FILE"

# Set Browser to Windows explorer so web links open in Windows web browser.
ensure_line_in_file 'export BROWSER=/mnt/c/Windows/explorer.exe' "$PROFILE_FILE"

# Enable true colour support in apps which check the COLORTERM variable.
# Most terminals which support true colour set this, but windows terminal does not.
# See: https://github.com/microsoft/terminal/issues/11057.
ensure_line_in_file 'export COLORTERM=truecolor' "$PROFILE_FILE"
