#!/bin/bash

# MARKED FOR REMOVAL
_case_id() {
	# EXPORT THE ID OPTION FOR THE TARGET
	eval _SYID="$(grep "$1" "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $2 }')"
	
	case "${_SYID}" in
		BYID)
			# EXPORT SDX{Y} DEVICE FROM DEVICE ID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			_tmp_type="$(blkid "/dev/disk/by-id/${_tmp_id}" | awk -F 'UUID=' '{ print $2 }' | cut -d ' ' -f 1 | cut -d '"' -f 2)"
			eval "$2"="$(blkid | grep "${_tmp_type}" | awk -F ':' '{ print $1 }')"
			;;
		UUID)
			# EXPORT SDX{Y} DEVICE FROM UUID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			eval "$2"="$(blkid | grep "${_tmp_id}" | awk -F ':' '{ print $1 }')"
			;;
		SDX)
			if ls "${_SYID}" >/dev/null 2>&1; then
				# SDX{Y} DEVICE
				eval "$2"="${_SYID}"
			else
				# SDX{Y} DEVICE
				_tmp_fs01="$(grep "$1" "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
				eval "$2"="${_tmp_fs01}"
				# THIS OPTION WILL BE USED TO IDENTIFY THE DEVICE.
				# IN SDX{Y} PARTITION IS MISSING, THE PROCESS WILL CREATE A NEW INTERFACE.
			fi
			;;
		*)
			echo "No local device matches $(blkid | grep "${_tmp_type}" | awk -F ':' '{ print $1 }')"
			return 1
			;;
	esac
	
	unset _tmp_fs01
	unset _tmp_i
	unset _tmp_type
}

# MARKED FOR REMOVAL
_scan_id_ty() {
	# CHECK IF { SYSFS, BOOTFS, BACKUPFS, USERDATAFS } LABELS EXIST
	_a_priori_devices

	# EXPORT SDX{Y} FOR SYSFS/BOOTFS/BACKUPFS/USERDATAFS
	if [[ "${_SYSLABEL}" == 0 ]]; then
		SYSDEV="$(blkid | grep "SYSFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_SYSLABEL}" == 1 ]]; then
		_case_id "SYSFS" "SYSDEV"
	fi

	if [[ "${_BOOTLABEL}" == 0 ]]; then
		BOOTDEV="$(blkid | grep "BOOTFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_BOOTLABEL}" == 1 ]]; then
		_case_id "BOOTFS" "BOOTDEV"
	fi

	if [[ "${_BACKUPLABEL}" == 0 ]]; then
		BACKUPDEV="$(blkid | grep "BACKUPFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_BACKUPLABEL}" == 1 ]]; then
		_case_id "BACKUPFS" "BACKUPDEV"
	fi

	if [[ "${_USERDATALABEL}" == 0 ]]; then
		USERDATADEV="$(blkid | grep "USERDATAFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_USERDATALABEL}" == 1 ]]; then
		_case_id "USERDATAFS" "USERDATADEV"
	fi

	eval "_PAR_BOOTDEV"="$(echo "${BOOTDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_BOOTDEV"="${BOOTDEV: -1}"

	eval "_PAR_SYSDEV"="$(echo "${SYSDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_SYSDEV"="${SYSDEV: -1}"

	eval "_PAR_BACKUPDEV"="$(echo "${BACKUPDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_BACKUPDEV"="${BACKUPDEV: -1}"

	eval "_PAR_USERDATADEV"="$(echo "${USERDATADEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_USERDATADEV"="${USERDATADEV: -1}"
}

# MARKED FOR REMOVAL
_bsu_dfs() {
	_scan_id_ty "$@"

	export BOOTDEV
	export SYSDEV
	export BACKUPDEV
	export USERDATADEV

	# EXPORT THE BOOT FILE SYSTEM TYPE
	BOOTFS="$(grep BOOTFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BOOTFS

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(grep SYSFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export SYSFS

	# EXPORT THE BACKUP FILE SYSTEM TYPE
	BACKUPFS="$(grep BACKUPFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BACKUPFS

	# EXPORT THE USERDATA FILE STSTEM TYPE
	USERDATAFS="$(grep USERDATAFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export USERDATAFS

	# EXPORT BOOT SIZE
	BOOTSFS="$(grep BOOTFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BOOTSFS

	# EXPORT SYSTEM SIZE
	SYSSFS="$(grep SYSFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export SYSSFS

	# EXPORT BACKUP SIZE
	BACKUPSFS="$(grep BACKUPFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BACKUPSFS

	# EXPORT USERDATA SIZE
	USERDATASFS="$(grep USERDATAFS "${CTCONFDIR}/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export USERDATASFS

	if [[ "${_ctflag_confd}" == 0 ]]; then
		_sources_exp
	fi
}
