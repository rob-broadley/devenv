# Set GPG_TTY to avoid “Inappropriate ioctl for device” error
export GPG_TTY=$(tty)

# Connect to existing keychain ssh-agent if running
[ -z $HOSTNAME ] && HOSTNAME=`uname -n`
[ -z "$KEYCHAIN_DIR" ] && export KEYCHAIN_DIR="$HOME/.cache/keychain"
[ -f $KEYCHAIN_DIR/$HOSTNAME-sh ] && source $KEYCHAIN_DIR/$HOSTNAME-sh
