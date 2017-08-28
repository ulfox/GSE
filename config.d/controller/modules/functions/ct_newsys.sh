#!/bin/bash

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



