#!/bin/bash

_chroot_config(){
	_revert_chroot() {
		if chroot "$1" "$2"; then
			return 0
		else
			return 1
		fi
	}

	_init_chroot() {
		if chroot "$1" "$2"; then
			echo "Configuration was successful"
			_sys_config=0
		else
			echo "Configuration failed"
			echo "Reverting changes"
			if _revert_chroot "$1" "var/tmp/ctworkdir/ccrevert_chroot.sh"; then
				echo "Changes reverted"
			else
				echo "Failed reverting changes"
				echo "Calling backup system"
			fi
			_sys_config=1
		fi
		export _sys_config
	}

	_prep_chroot() {
		if _mount_sysfs "$1" && _mount_pseudos "$1"; then
			mkdir -p "$1/var/tmp/ctworkdir"
			cp -r "${CTCONFDIR}/confdir" "$1/var/tmp/ctworkdir/"
			cp "/usr/local/controller/cchroot.sh" "$1/var/tmp/ctworkdir/cchroot"
			_init_chroot "$@" 
		else
			_sys_config=1
			export _sys_config
		fi
	}

	if _unmount "$1"; then
		_prep_chroot "$@"
	else
		_sys_config=1
		export _sys_config
	fi
}