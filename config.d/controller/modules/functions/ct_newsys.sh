#!/bin/bash

_bsu_dfs() {
	#/DEV/SDX
	SYSDEV="$(blkid | grep "SYSFS" | awk -F ':' '{ print $1 }')"
	BACKUPDEV="$(blkid | grep "BACKUPFS" | awk -F ':' '{ print $1 }')"
	BOOTDEV="$(blkid | grep "BOOTFS" | awk -F ':' '{ print $1 }')"
	USERDATADEV="$(blkid | grep "USERDATAFS" | awk -F ':' '{ print $1 }')"

	export SYSDEV
	export BACKUPDEV
	export USERDATADEV
	export BOOTDEV

	# EXPORT SYSTEM'S FS
	SYSFS="$(blkid | grep "LABEL=\"SYSFS\"" | awk -F ' ' '{print $4}' | awk -F '=' '{print $2}' | sed 's/\"//g')"
	export SYS

	# EXPORT BACKUP's FS
	BACKUPFS="$(blkid | grep "LABEL=\"BACKUPFS\"" | awk -F ' ' '{print $4}' | awk -F '=' '{print $2}' | sed 's/\"//g')"
	export BACKUPFS
}

_remake() {
	if eval "mkfs.$1" "$2" "$3" "$4"; then
		return 0
	else
		return 1
	fi
}

_remake_dev() {
	if _unmount "$1"; then
		if [[ "${SYSFS}" == 'btrfs' ]]; then
			wipefs "$2"
			if _remake "${SYSFS}" "-f -L" "SYSFS" "$2"; then
				echo "File system created"
				_ctflag_remake=0
			else
				echo "Failed creating new filesystem"
				_ctflag_remake=1
			fi
		else
			wipefs "$2"
			if _remake "${SYSFS}" "-F -L" "SYSFS" "$2"; then
				echo "File system created"
				_ctflag_remake=0
			else
				echo "Failed creating new filesystem"
				_ctflag_remake=1
			fi
		fi
	else
		echo "Failed unmounting /mnt/workdir"
		_ctflag_remake=1
	fi
	export _ctflag_remake
}