#!/bin/sh

ensure_line_in_file () {
	grep -qF "$1" "$2" || ( echo "$1" >> "$2" && return 10 )
}

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

# Give password-less sudo. This is only acceptable as it is a private
# development environment not exposed to the outside world.
# Do NOT do this on your host machine or otherwise.
echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Make neovim load WSL specific config.
ensure_line_in_file "lua require('wsl')" '/etc/xdg/nvim/sysinit.vim'
