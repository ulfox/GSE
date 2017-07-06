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

source "${CTSCRIPTS}/cnetwork.sh"

# WIPE OLD FS, CREATE NEW FS & FETCH NEW SYSTEM
if [[ "${_ctflag_sysfetch}" == 0 ]]; then
	_remake_sysfs
	_fetch_new_sys
fi

# CONFIGURATION
if [[ "${_ctflag_net}" ]]; then
	_mount_sysfs
	_chroot_config "$/mnt/workdir" "workdir"
fi