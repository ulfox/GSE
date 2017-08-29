#!/bin/bash

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
# MAKE SURE RFS BFS WORKDIR ARE NOT MOUNTED
_unmount_all_targets

if grep -q "ctetc=1" "/proc/cmdline"; then
	_extract_target() {
		(
			cd "$1"
			rm -f "/tmp/verify.info"
			if tar xvjpf "$2" --xattrs --numeric-owner >/dev/null; then
				echo "PASS" > "/tmp/verify.info"
				rm -f "$2"
			else
				echo "FAIL" > "/tmp/verify.info"
			fi
		)
	}
	
	_unmount "/sysroot/etc"

	if grep -q "bootetc=1" "/proc/cmdline"; then
		mkdir -p "/bootetc"
		mount -t tmpfs tmpfs "/sysroot/etc"
		
		mount -L "BOOTFS" "/bootetc"
		cp "/bootetc/etc.tar.bz2" "/sysroot/etc/etc.tar.bz2"
		_extract_target "/sysroot/etc" "etc.tar.bz2"
		if grep -q "PASS" "/tmp/verify.info"; then
			echo "etc configured successfully"
		else
			echo "etc failed to configure"
			umount -l "/sysroot/etc"
		fi
		
		umount -l "/bootetc"
	else
		cp -r "/sysroot/etc" "/tmpfs_etc"
		mount -t tmpfs tmpfs "/sysroot/etc"
		rsync -aAPhrq "/tmpfs_etc" "/sysroot/etc/"
	fi
fi

if grep -q "ctvar=1" "/proc/cmdline" && grep -q "bootvar=1" "/proc/cmdline"; then
	_unmount "/sysroot/var"

	mount -t tmpfs tmpfs "/sysroot/var"
	mkdir -p "/bootvar"
	mount -L "BOOTFS" "/bootvar"
		cp "/bootetc/var.tar.bz2" "/sysroot/var/var.tar.bz2"
		_extract_target "/sysroot/etc" "etc.tar.bz2"
		if grep -q "PASS" "/tmp/verify.info"; then
			echo "var configured successfully"
		else
			echo "var failed to configure"
			umount -l "/sysroot/var"
		fi
		
		umount -l "/bootvar"
elif grep -q "ctvar_tmp=1" "/proc/cmdline"; then
	_unmount "/sysroot/var"

	mount -t tmpfs tmpfs "/sysroot/var/tmp"
fi

if grep -q "cttmp=1" "/proc/cmdline"; then
	_unmount "/sysroot/tmp"

	mount -t tmpfs tmpfs "/sysroot/tmp"
fi


