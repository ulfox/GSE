#!/bin/bash

# This is the first controller's script.
# The script is sourced at pre-mount hook points, after udev has finished with a priority of 08.

# EXPORT CONTROLLER CONFDIR
CTCONFDIR=/config.d
export CTCONFDIR

# EXPORT LOCAL SCRIPTDIR
CTSCRIPTS=/usr/local/controller
export CTSCRIPTS

# UPDATE PATH
export "PATH=${PATH}:/usr/local/controller"

# CONTROLLER FUNCTIONS
source "${CTSCRIPTS}/ct_prelim.sh"

_a_priori_devices

# NETWORK SCRIPT
source "${CTSCRIPTS}/cnetwork.sh"

# CHECK NETWORK FLAG AND FETCH VERSION AND CONFIG.D DIRECTORY
if [[ "${_ctflag_net}" == 0 ]]; then
	source "${CTSCRIPTS}/ct_fetch.sh"

	# EXPORT SERVER'S INFO
	_sources_exp

	# MOUNT SYSFS AS RW
	_mount_sysfs "/mnt/workdir"

	# FETCH CONFIG.D
	_fetch_confd

	# FETCH LATEST VERSION
	_fetch_version

	# MOUNT SYSFS AS RW
	_mount_sysfs "/mnt/workdir"
	# CHECK LOCAL VERSION OF SYSFS WITH SERVERS VERSION
	_check_version

	# IMPORT GPG PUB KEY
	# _gpg_import

	source "${CTSCRIPTS}/ct_newsys.sh"
	_bsu_dfs

	# WIPE OLD FS, CREATE NEW FS & FETCH NEW SYSTEM
	if [[ "${_ctflag_switch}" != '0' ]]; then
		if [[ "${_ctflag_sysfetch}" == 0 && "${_ctflag_net}" == 0 ]]; then
			# WIPE & CREATE NEW FS
			_remake_dev "/mnt/workdir" "${SYSDEV}"
			
			# FETCH NEW SYSTEM
			if [[ "${_ctflag_remake}" == 0 ]]; then
				_fetch_new_sys "/mnt/workdir"
			elif [[ "${_ctflag_remake}" == 1 ]]; then
				_call_backup_switch
			fi

			# VERIFY FETCHED IMAGE
			if [[ "${_ctflag_fetch}" == 0 ]]; then
				_verify_target "/mnt/workdir"
			elif [[ "${_ctflag_fetch}" == 1 ]]; then
				_call_backup_switch
			fi

			# EXTRACT NEW SYSTEM
			if [[ "${_ctflag_verify}" == 0 ]]; then
				_extract_sys "/mnt/workdir" "${_sys_archive}"
				rm -f "/mnt/workdir/verify.info"
				if _check_last "/mnt/workdir"; then
					_ctflag_extract=0
				else
					_ctflag_extract=1
				fi
				export _ctflag_extract
			elif [[ "${_ctflag_verify}" == 1 ]]; then
				_call_backup_switch
			fi
		fi
	fi
fi

if [[ "${_ctflag_switch}" == 0 ]]; then
	

return 1
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
