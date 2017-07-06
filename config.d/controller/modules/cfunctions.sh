#!/bin/bash

die() {
	echo "$@" 1>&2 ; exit 1
}

_bsu_dfs() {
	# EXPORT BOOT DEVICE
	BOOTDEV="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $2 }')"
	export BOOTDEV

	# EXPORT SYSTEM DEVICE
	SYSDEV="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $2 }')"
	export SYSDEV

	# EXPORT BACKUP DEVICE
	BACKUPDEV="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BACKUP | awk -F ' ' '{ print $2 }')"
	export BACKUPDEV

	# EXPORT USERDATA DEVICE
	USERDATADEV="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $2 }')"
	export USERDATADEV

	# EXPORT THE BOOT FILE SYSTEM TYPE
	BOOTFS="$(cat "${CTCONFDIR}/confdir/fstab.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $2 }')"
	export BOOTFS

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(cat "${CTCONFDIR}/confdir/fstab.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $2 }')"
	export SYSFS

	# EXPORT THE BACKUP FILE SYSTEM TYPE
	BACKUPFS="$(cat "${CTCONFDIR}/confdir/fstab.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BACKUP | awk -F ' ' '{ print $2 }')"
	export BACKUPFS

	# EXPORT THE USERDATA FILE STSTEM TYPE
	USERDATAFS="$(cat "${CTCONFDIR}/confdir/fstab.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $2 }')"
	export USERDATAFS

	# EXPORT BOOT SIZE
	BOOTSFS="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BOOT | awk -F ' ' '{ print $3 }')"
	export BOOTSFS

	# EXPORT SYSTEM SIZE
	SYSSFS="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep SYS | awk -F ' ' '{ print $3 }')"
	export SYSSFS

	# EXPORT BACKUP SIZE
	BACKUPSFS="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep BACKUP | awk -F ' ' '{ print $3 }')"
	export BACKUPSFS

	# EXPORT USERDATA SIZE
	USERDATASFS="$(cat "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | grep USERDATA | awk -F ' ' '{ print $3 }')"
	export USERDATASFS

	if [[ "$_ctflag_net" ]]; then
		_sources_exp
	fi
}

server_exp() {
	echo "Selecting server..."
	_ser_list=()
	while read -r "s";do
		_ser_list+=("${s}")
	done < "${CTCONFDIR}/sources/servers"
	
	if [[ "${#_ser_list[@]}" -ge 1 ]]; then
		_act_ser_ar=()
		for i in "${_ser_list[@]}"; do
			avms=$(ping -c 3 "$i" | tail -1| awk -F '/' '{print $5}')
			_act_ser+=("${avms}")
		done
	else
		avms=$(ping -c 3 "${_ser_list[0]}" | tail -1| awk -F '/' '{print $5}')
		_act_ser="${avms}"
	fi

	_max_entry="${_ser_list[0]}"
	for n in "${_ser_list[@]}" ; do
	    if [[ "$n" != '' ]]; then
		    ((${n%.*} > ${_max_entry%.*})) && _max_entry="$n"
		fi
	done
	_act_ser="${_max_entry}"
}

_sources_exp() {
	# SOURCE THE SOURCES CONFIGURATION FILES FOR EXPORTING THE SERVER INFORMATIONS
	source "${CTCONFDIR}/confdir/sources/sources.conf"

	if [[ -z "${_conf_dir}" ]]; then
		_conf_dir="$(grep "confdir" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _conf_dir
	fi

	if [[ -z "${_dist_dir}" ]]; then
		_dist_dir="$(grep "distdir" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _dist_dir
	fi

	if [[ -z "${_ser_user}" ]]; then
		_ser_user="$(grep "user" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _ser_user
	fi
}

_call_net() {
	ifconfig "${_net_interface}" up
	udhcpc -t 5 -q -s "/bin/net_script.sh"
}

_mount_sysfs() {
	if mount -t "${SYSFS}" -o rw "${SYSDEV}" "$1"; then
		return 0
	else
		return 1
	fi
}

_call_backup_switch() {
	_ctflag_active_system="BACKUPDEV"
	export _ctflag_active_system
}

_question() {
	for i in "$@"; do
		[[ "$i" ]] && echo "$i"
	done
	while true; do
		echo "Answer: Y/N "
		read -rp "Input :: <= " ANS
		case "${ANS}" in
			[yY])
				return 0
				break;;
			[nN]])
				return 1
				break;;
		esac
	done

	unset ANS
	unset _question_yes_action
	unset _question_no_action
}

_fetch_version() {
	if scp "${_act_user}@${_act_ser}/${_conf_dir}" "${CTCONFDIR}/version"; then
		_ctflag_sverison=0
	else
		_ctflag_sversion=1
	fi
	export _ctflag_sversion
}

_fetch_confd() {
	if rsync -aAXPhrv "${_act_user}@${_act_ser}/${_conf_dir}" "${CTCONFDIR}/confdir/"; then
		_ctflag_confd=0
	else
		_ctflag_confd=1
	fi
	export _ctflag_confd
}

_check_version() {
	_fetch_version

	if [[ "${_ctflag_sversion}" == 0 ]]; then
		_local_version="$(cat "/mnt/workdir/var/lib/version")"
		_server_version="$(cat "${CTCONFDIR}/version")"
	if [[ "${_local_version}" != "${_server_version}" ]]; then
		if [[ -z "${_ctflag_nohuman}" ]]; then
			if _question "A new System Version is present on the server" "Do you wish to fetch the new system?"; then
				_ctflag_sysfetch=0
			else
				_ctflag_sysfetch=1
			fi
			export _ctflag_sysfetch
		else
			_ctflag_sysfetch=0
			export _ctflag_sysfetch
		fi
	else
		echo "Remote version matches the local"
	fi
}

mv_pseudo() {	# ${rsys}
	# Moving sys proc dev to rfs
	echo "Moving sys proc dev to rfs"
	for i in sys proc dev
	do
		echo "Moved ${i} to $1/${i}"
		mount --move "$2/${i}" "$1/${i}"
	done
}

mount_pseudo() {
	mount -t proc /proc "$1/proc" || return 1
	mount --rbind /dev "$1/dev" || return 1
	mount --rbind /sys "$1/sys" || return 1
	mount --make-rslave "$1/dev" || return 1
	mount --make-rslave "$1/sys" || return 1
}

umount_pseudo() {
	umount -l "$1/proc" >/dev/null 2>&1
	umount -l "$1/dev" >/dev/null 2>&1
	umount -l "$1/sys" >/dev/null 2>&1
	umount -l "$1"/* >/dev/null 2>&1
}

_unmount() {
	k=0
	if [[ -n "$(grep "mnt/$2" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		while true; do
			while read -r i; do
				eval umount -l "$i"/* >/dev/null 2>&1
				eval umount -l "$i" >/dev/null 2>&1
			done < <(grep "/mnt/$2" "/proc/mounts" | awk -F ' ' '{ print $2 }')
			
			if [[ -z $(grep "/mnt/$2" "/proc/mounts" | awk -F ' ' '{ print $2 }') ]]; then
				break
			fi
		
			[[ "$k" -ge 20 ]] && return 1
			((++k))
		done
	return 0
	fi
}

_chroot_config(){
	if _unmount "$1" "$2"; then
		if mount_fs && mount_pseudo "$1"; then
			mkdir -p "$1/var/tmp/ctworkdir"
			cp -r "${CTCONFDIR}/confdir" "$1/var/tmp/ctworkdir/"
			cp "/usr/local/controller/cchroot.sh" "$1/var/tmp/ctworkdir/cchroot"
			
			if chroot "$1" "var/tmp/ctworkdir/cchroot"; then
				echo "Configuration was successful"
			else
				echo "Configuration failed"
				echo "Reverting changes"
				if _revert_chroot; then
					echo "Changes reverted"
				else
					echo "Failed reverting changes"
					echo "Calling backup system"
				fi
			fi
		else
			echo "Failed mounting pseudo filesystems"
			echo "Configuration can not proceed"
			_flag_config_check=1
			export _flag_config_check
			echo "Proceeding"
		fi
	else
		echo "Something went wrong"
		echo "Proceeding without configuration"
		_flag_config_check=1
		export _flag_config_check
	fi
}

_remake_sysfs() {
	if umount "/mnt/workdir"; then
		if [[ "${SYSFS}" == 'btrfs' ]]; then
			if eval "mkfs.${SYSFS}" -L ROOTFS -f "${SYSDEV}"; then
				echo "File system created"
			else
				echo "Failed creating new filesystem"
				_call_backup_switch
			fi
		else
			if eval "mkfs.${SYSFS}" -L ROOTFS "${SYSDEV}"; then
				echo "File system created"
			else
				echo "Failed creating new filesystem"
				_call_backup_switch
			fi
		fi
	else
		echo "Failed unmounting workdir"
		_call_backup_switch
	fi
}

_fetch_new_sys() {
	if _mount_sysfs "/mnt/workdir"; then
		if sync -aAXhq "${_M_SERVER}/dist.d/stage3-amd64-${_server_version}.tar.bz2"  "${CTCONFDIR}/version"; then
			echo "New system was fetched successfully"
			_ctflag_active_system="SYSDEV"
		else
			echo "Fetching new system FAILED"
			_call_backup_switch
		fi
	else
		echo "Failed mounting ${SYSDEV} to /mnt/workdir"
		_call_backup_switch
	fi
}
