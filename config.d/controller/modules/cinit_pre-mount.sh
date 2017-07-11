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
if [[ "${_ctflag_sysfetch}" == 0 && "${_ctflag_net}" == 0 ]]; then
	# WIPE & CREATE NEW FS
	_remake_sysfs "/mnt/workdir"
	
	# FETCH NEW SYSTEM
	if [[ "${_ctflag_remake}" == 0 ]]; then
		_fetch_new_sys "/mnt/workdir"
	elif [[ "${_ctflag_remake}" == 1 ]]; then
		_call_backup_switch
	fi

	# VERIFY FETCHED IMAGE
	if [[ "${_ctflag_fetch}" == 0 ]]; then
		_verify_t "/mnt/workdir"
	elif [[ "${_ctflag_fetch}" == 1 ]]; then
		_call_backup_switch
	fi

	# EXTRACT NEW SYSTEM
	if [[ "${_ctflag_verify}" == 0 ]]; then
		_extract_sys "/mnt/workdir"
		rm -f "/mnt/workdir/verify.info"
		if _check_s "/mnt/workdir"; then
			_ctflag_extract=0
		else
			_ctflag_extract=1
		fi
		export _ctflag_extract
	elif [[ "${_ctflag_verify}" == 1 ]]; then
		_call_backup_switch
	fi
fi

# CONFIGURATION
if [[ "${_ctflag_net}" == 0 ]] && [[ "${_ctflag_confd}" == 0 || "${_ctflag_extract}" == 0 ]]; then
	# MOUNT SYSTEM
	if _mount_sysfs "/mnt/workdir"; then
		# CHROOT SYSTEM AND INITIATE THE CCHROOT.SH
		_chroot_config "$/mnt/workdir" "var/tmp/ctworkdir/cchroot"
		if [[ "{_ctflag_extract}" == 0 && "${_sys_config}" == 1 ]]; then
			_call_backup_switch
		fi
	else
		echo "Could not mout sysfs @ /mnt/workdir"
	fi
fi