#!/bin/bash

# EXPORT IMPORTANT VARIABLES BEFORE GOING ON
source "/etc/profile" && export PS1="( 'Configuration Phase' ) $PS1"
env-update > /dev/null 2>&1
CHROOT_DIR="var/tmp/ctworkdir"
export CHROOT_DIR
PATH=${PATH}:${CHDIR}
export PATH

if source "${CHROOT_DIR}/cchroot_functions.sh"; then
	echo -e "[\e[32m*\e[0m] Exporting chroot functions"
else
	echo -e "[\e[31m*\e[0m] Failed to export chroot functions, aborting"
	exit 1
fi

case "$1" in
	chroot)
		_ctflag_chroot="chroot";;
	revert)
		_ctflag_chroot="revert";;
esac

export _ctflag_chroot

# CONFIGURATION FILES
_configure_system

# RUNLEVELS
_runlevel_configuration

