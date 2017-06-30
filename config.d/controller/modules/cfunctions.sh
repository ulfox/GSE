#!/bin/bash

_bsu_dfs() {
	# EXPORT BOOT DEVICE
	BOOTDEV="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $2 }')"
	export BOOTDEV

	# EXPORT SYSTEM DEVICE
	SYSDEV="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $2 }')"
	export SYSDEV

	# EXPORT USERDATA DEVICE
	USERDATADEV="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $2 }')"
	export USERDATADEV

	# SOURCE THE SOURCES CONFIGURATION FILES FOR EXPORTING THE SERVER INFORMATIONS
	source "${CTCONFDIR}/sources/sources.conf"

	# EXPORT THE BOOT FILE SYSTEM TYPE
	BOOTFS="$(cat fstab.info | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $2 }')"
	export BOOTFS

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(cat fstab.info | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $2 }')"
	export SYSFS

	# EXPORT THE USERDATA FILE STSTEM TYPE
	USERDATAFS="$(cat fstab.info | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $2 }')"
	export USERDATAFS

	# EXPORT BOOT SIZE
	BOOTSFS="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $3 }')"
	export BOOTSFS

	# EXPORT SYSTEM SIZE
	SYSSFS="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $3 }')"
	export SYSSFS

	# EXPORT USERDATA SIZE
	USERDATASFS="$(cat devname.info | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $3 }')"
	export USERDATASFS
}