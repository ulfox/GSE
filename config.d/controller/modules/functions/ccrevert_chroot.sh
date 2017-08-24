#!/bin/bash

# EXPORT IMPORTANT VARIABLES BEFORE GOING ON
source /etc/profile && export PS1="( 'Configuration Phase' ) $PS1"
CHROOT_DIR="var/tmp/ctworkdir/"
export CHROOT_DIR
PATH=${PATH}:${CHDIR}
export PATH
if source "${CHROOT_DIR}/cchroot_functions"; then
	echo "Exporting chroot functions"
else
	echo "Failed to export chroot functions, aborting"
	exit 1
fi

_ctflag_chroot="revert"
export _ctflag_chroot

# REVERT CONFIGURATION FILES
_configure_system

# REVERT RUNLEVELS
_runlevel_configuration