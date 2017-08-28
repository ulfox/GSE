#!/bin/bash

_chroot_config(){
	_init_chroot() {
		if chroot "$1" "$2/cchroot.sh" "chroot"; then
			echo -e "[\e[32m*\e[0m] Configuration was successful"
			_sys_config=0
		else
			echo -e "[\e[31m*\e[0m] Configuration failed"
			echo -e "[\e[33m*\e[0m] Reverting changes"
			echo -e "[\e[33m*\e[0m]Initiating revert function"
			if chroot "$1" "$2/cchroot.sh" "revert"; then
				echo -e "[\e[32m*\e[0m] Changes reverted"
				_sys_revert=0
			else
				_sys_revert=1
				echo -e "[\e[31m*\e[0m] Failed reverting changes"
				echo -e "[\e[33m*\e[0m] Calling backup system"
			fi
			export _sys_revert
			_sys_config=1
		fi
		export _sys_config
	}

	_prep_chroot() {
		if _mount_sysfs "$1" && _mount_pseudos "$1"; then
			mkdir -p "$1/$2"

			cp -r "${CTCONFDIR}"/confdir/system_configs/* "$1/$2/"
			cp "/usr/local/controller/cchroot.sh" "$1/$2/"
			cp "/usr/local/controller/cchroot_functions.sh" "$1/$2/"
			_init_chroot "$@" 
		else
			echo -e "[\e[33m*\e[0m] Failed initiating chroot functions"
			_sys_config=1
			export _sys_config
		fi
	}

	echo -e "[\e[34m*\e[0m] Initiating chroot"
	_prep_chroot "$@"
}
