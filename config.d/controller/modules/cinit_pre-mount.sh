#!/bin/bash

# This is the first controller's script.
# The script is sourced at pre-mount hook points, after udev has finished with a priority of 08.

# EXPORT CONTROLLER CONFDIR
CTCONFDIR=/config.d
export CTCONFDIR

unset _ctflag_switch

# EXPORT LOCAL SCRIPTDIR
CTSCRIPTS=/usr/local/controller
export CTSCRIPTS

# UPDATE PATH
export "PATH=${PATH}:/usr/local/controller"

# CONTROLLER FUNCTIONS
source "${CTSCRIPTS}/ct_prelim.sh"

_a_priori_devices
_bsu_dfs

if [[ ! -e "${SYSDEV}" ]] || [[ ! -e "${BACKUPDEV}" ]]; then
	_recheck_dev() {
		_a_priori_devices
		_bsu_dfs

		if [[ -e "${SYSDEV}" && -e "${BACKUPDEV}" ]]; then
			return 0
		else
			return 1
		fi
	}

	_rescue_shell "Important labels are missing." "Please create the partitions you wish with SYSFS and BACKUPFS labels"
fi

# IMPORT GPG PUB KEY
_gpg_import

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

	source "${CTSCRIPTS}/ct_newsys.sh"

	# WIPE OLD FS, CREATE NEW FS & FETCH NEW SYSTEM
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
			if ! _verify_target "/mnt/workdir"; then
				_call_backup_switch
			fi
		elif [[ "${_ctflag_fetch}" == 1 ]]; then
			_call_backup_switch
		fi

		# EXTRACT NEW SYSTEM
		if [[ "${_ctflag_verify}" == 0 ]]; then
			rm -f "/mnt/workdir/verify.info"
			_extract_sys "/mnt/workdir" "${_sys_archive}"

			if _check_last "/mnt/workdir"; then
				_ctflag_extract=0
			else
				_ctflag_extract=1
			fi

			rm -f "/mnt/workdir/verify.info"
			export _ctflag_extract
		elif [[ "${_ctflag_verify}" == 1 ]]; then
			_call_backup_switch
		fi
	fi
	_unmount "/mnt/workdir"
fi

if [[ "${_ctflag_switch}" == 0 ]]; then
	echo "switch $_ctflag_switch"
	return 1
fi

# BACKUP SWITCH CONDITION
if [[ "${_ctflag_switch}" == 0 ]]; then
	if [[ "${SYSFS}" == 'ext4' ]]; then
		e2label "${SYSDEV}" "EXPIRED"
		e2label "${BACKUPDEV}" SYSFS
	elif [[ "${SYSFS}" == 'btrfs' ]]; then
		btrfs filesystem label "${SYSDEV}" "EXPIRED"
		btrfs filesystem label "${BACKUPDEV}" "SYSFS"
	fi
	
	SYSFS_EXPIRED="${SYSFS}"
	SYSFS="${BACKUPFS}"

	SYSDEV_EXPIRED="${SYSDEV}"
	SYSDEV="${BACKUPDEV}"
	
	_unmount "/mnt/workdir"
fi

# CONFIGURATION
if [[ "${_ctflag_net}" == 0 ]] && [[ "${_ctflag_confd}" == 0 || "${_ctflag_extract}" == 0 ]]; then
	source "/usr/local/controller/ct_config.sh"
return 1
	# CHROOT SYSTEM AND INITIATE THE CCHROOT.SH
	if _chroot_config "/mnt/workdir" "var/tmp/ctworkdir/cchroot"; then
		if [[ "${_sys_config}" == 1 ]]; then
			_call_backup_switch
		fi
	fi
	_unmount "/mnt/workdir"
fi
