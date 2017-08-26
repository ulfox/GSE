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
# CONTROLLER PRELIMINARY FUNCTIONS
source "${CTSCRIPTS}/ct_prelim.sh"
# MAKE SURE CT FLAGS ARE NOT SET
_unset_ct
# CHECK AND EXPORT LABELS
_a_priori_devices
# EXPORT DEVICES AND FILESYSTEMS
_bsu_dfs
# CHECK IF ROOTFS AND BACKUPFS HAVE ROOT SYSTEMS INSIDE
_check_rbfs

# CASE OF MISSING SYSFS DEVICE OR BOOTFS DEVICE
# THIS SHOULD NEVER HAPPEN, BUT IT'S POSSIBLE SOMETIMES.
# AN EXAMPLE WOULD BE A FAILURE OF MKFS.${FS} DURING THE PROCESS
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

	while true; do
		_rescue_shell "Important labels are missing." "Please create the partitions you wish with SYSFS and BACKUPFS labels"

		if _recheck_dev; then
			break
		fi
	done
fi


# IMPORT GPG PUB KEY
# THIS FEATURE IS DISABLED FOR NOW
# _gpg_import

# NETWORK SCRIPT
source "${CTSCRIPTS}/cnetwork.sh"

# CHECK NETWORK FLAG AND FETCH VERSION AND CONFIG.D DIRECTORY
if [[ "${_ctflag_net}" == 0 ]]; then
	# FETCH FUNCTIONS
	source "${CTSCRIPTS}/ct_fetch.sh"
	# NEW SYSTEM FUNCTIONS
	source "${CTSCRIPTS}/ct_newsys.sh"
	# EXPORT SERVER'S INFO
	_sources_exp
	# FETCH CONFIG.D
	_fetch_confd
	# FETCH LATEST VERSION
	_fetch_version

	if [[ "${_ctflag_setup}" == 0 ]]; then
		_ctflag_sysfetch=0
		_ctflag_bconf=0
	elif [[ "${_ctflag_setup}" == 1 ]]; then
		_call_backup_switch
	else
		# MOUNT SYSFS AS RW
		_mount_sysfs "/mnt/workdir"
		# CHECK LOCAL VERSION OF SYSFS WITH SERVERS VERSION
		_check_version
		_unmount "/mnt/workdir"
	fi
fi

# WIPE OLD FS, CREATE NEW FS & FETCH NEW SYSTEM
# _CTFLAG_SYSFETCH IS DEFINED @ _CHECK_VERSION
# _CTFLAG_NET IS DEFINED @ CNETWORK.SH
if [[ "${_ctflag_sysfetch}" == 0 && "${_ctflag_net}" == 0 ]]; then
	_case_fail() {
		if [[ "${_ctflag_bconf}" == 0 ]]; then
			_rescue_shell "Process failed" "Backup system is missing"
		else
			_call_backup_switch
		fi
	}

	# WIPE & CREATE NEW FS
	_remake_dev "/mnt/workdir" "${SYSDEV}"
	# FETCH NEW SYSTEM
	# _CTFLAG_REMAKE IS DEFINED @ _RMAKE_DEV
	if [[ "${_ctflag_remake}" == 0 ]]; then
		_fetch_new_sys "/mnt/workdir"
	elif [[ "${_ctflag_remake}" == 1 ]]; then
		_case_fail
	fi

	# VERIFY FETCHED IMAGE
	# _CTFLAG_FETCH IS DEFINE @ _FETCH_NEW_SYS
	if [[ "${_ctflag_fetch}" == 0 ]]; then
		if ! _verify_target "/mnt/workdir"; then
			_call_backup_switch
		fi
	elif [[ "${_ctflag_fetch}" == 1 ]]; then
		_case_fail
	fi

	# EXTRACT NEW SYSTEM
	if [[ "${_ctflag_verify}" == 0 ]]; then
		# CASE OF A LEFTOVER CHECK
		rm -f "/mnt/workdir/verify.info"
		# EXTRACT SYSTEM TARBALL
		# _SYS_ARCHIVE IS DEFINED @ _FETCH_NEW_FS
		_extract_sys "/mnt/workdir" "${_sys_archive}"
		if _check_last "/mnt/workdir"; then
			_ctflag_extract=0
		else
			_ctflag_extract=1
		fi

		rm -f "/mnt/workdir/verify.info"
		export _ctflag_extract
	elif [[ "${_ctflag_verify}" == 1 ]]; then
		_case_fail
	fi

	_unmount "/mnt/workdir" 
elif [[  "${_ctflag_setup}" == 1 && "${_ctflag_net}" == 1 ]]; then
	_call_backup_switch
elif [[ "${_ctflag_setup}" == 0 && "${_ctflag_net}" == 1 ]]; then
	_rescue_shell "No active system could be located, neither a network connection could be established from a system fetch"
fi

if [[ "${_ctflag_switch}" == 0 ]]; then
	echo "switch $_ctflag_switch"
	return 1
fi

# BACKUP SWITCH CONDITION
# _CTFLAG_SWITCH IS DEFINED FROM ALL _CALL_BACKUP_SWITCH
if [[ "${_ctflag_switch}" == 0 ]]; then
	SYSFS_EXPIRED="${SYSFS}"
	SYSDEV_EXPIRED="${SYSDEV}"

	if [[ "${SYSFS}" == 'ext4' ]]; then
		e2label "${SYSDEV}" "EXPIRED"
		e2label "${BACKUPDEV}" SYSFS
	elif [[ "${SYSFS}" == 'btrfs' ]]; then
		btrfs filesystem label "${SYSDEV}" "EXPIRED"
		btrfs filesystem label "${BACKUPDEV}" "SYSFS"
	fi

	SYSFS="${BACKUPFS}"
	SYSDEV="${BACKUPDEV}"
	
	_unmount "/mnt/workdir"
fi

# CONFIGURATION
# _CTFLAG_CONFD IS DEFINED @ _FETCH_CONFD
# _CTFLAG_EXTRACT IS DEFINED @ _EXTRACT_SYS
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

_mount_target "/mnt/rfs" "${SYSFS}" "SYSFS"
_mount_target "/mnt/bfs" "${BACKUPFS}" "BACKUPFS"

_sync_backupfs

_unmount "/mnt/rfs"
_unmount "/mnt/bfs"