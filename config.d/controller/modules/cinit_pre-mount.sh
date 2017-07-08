#!/bin/bash

# EXPORT CONTROLLER CONFDIR
CTCONFDIR=/config.d
export CTCONFDIR

# EXPORT LOCAL SCRIPTDIR
CTSCRIPTS=/usr/local/controller
export CTSCRIPTS

# UPDATE PATH
export "PATH=${PATH}:/usr/local/controller"

# CONTROLLER FUNCTIONS
source "${CTSCRIPTS}/cfunctions.sh"

# NETWORK SCRIPT
source "${CTSCRIPTS}/cnetwork.sh"

# WIPE OLD FS, CREATE NEW FS & FETCH NEW SYSTEM
if [[ "${_ctflag_sysfetch}" == 0 && -n "${_ctflag_net}" ]]; then
	# WIPE & CREATE NEW FS
	_remake_sysfs "/mnt/workdir"
	# FETCH NEW SYSTEM
	_fetch_new_sys "/mnt/workdir"
	# EXTRACT NEW SYSTEM
	_extract_sys "/mnt/workdir" "${_sys_archive}"
fi

# CONFIGURATION
if [[ "${_ctflag_net}" ]]; then
	# MOUNT SYSTEM
	_mount_sysfs "/mnt/workdir"
	# CHROOT SYSTEM AND INITIATE THE CCHROOT.SH
	_chroot_config "$/mnt/workdir" "var/tmp/ctworkdir/cchroot"
fi

