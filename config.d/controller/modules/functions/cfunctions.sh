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

	if [[ "${_ctflag_confd}" == 0 ]]; then
		_sources_exp
	fi
}

_server_exp() {
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
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

	if mount -t "${SYSFS}" -o rw "${SYSDEV}" "$1"; then
		return 0
	else
		return 1
	fi
}

_call_backup_switch() {
	_ctflag_bootflag="BACKUP"
	export _ctflag_bootflag
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
	if scp "${_act_user}@${_act_ser}/${_dist_dir}" "${CTCONFDIR}/version"; then
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
		if [[ -n "${_ctflag_human}" ]]; then
			if _question "A new System Version is present on the server" "Do you wish to fetch the new system?"; then
				_ctflag_sysfetch=0
			else
				_ctflag_sysfetch=1
			fi
		else
			_ctflag_sysfetch=0
		fi
	else
		echo "Remote version matches the local"
		_ctflag_sysfetch=1
	fi
	export _ctflag_sysfetch
}

mv_pseudo() {	# ${rsys}
	# Moving sys proc dev to rfs
	echo "Moving sys proc dev to rfs"
	for i in sys proc dev
	do
		echo "Moved ${i} to $2/${i}"
		mount --move "$1/${i}" "$2/${i}"
	done
}

mount_pseudo() {
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

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
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		while true; do
			while read -r i; do
				eval umount -l "$i"/* >/dev/null 2>&1
				eval umount -l "$i" >/dev/null 2>&1
			done < <(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')
			
			if [[ -z $(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }') ]]; then
				break
			fi
		
			[[ "$k" -ge 20 ]] && return 1
			((++k))
		done
	return 0
	fi
}

_chroot_config(){
	_revert_chroot() {
		if chroot "$1" "$2"; then
			return 0
		else
			return 1
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
		if _mount_sysfs "$1" && mount_pseudo "$1"; then
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

_remake_sysfs() {
	if _unmount "$1"; then
		if [[ "${SYSFS}" == 'btrfs' ]]; then
			if eval "mkfs.${SYSFS}" -L ROOTFS -f "${SYSDEV}"; then
				echo "File system created"
				_ctflag_remake=0
			else
				echo "Failed creating new filesystem"
				_ctflag_remake=1
			fi
		else
			if eval "mkfs.${SYSFS}" -L ROOTFS "${SYSDEV}"; then
				echo "File system created"
				_ctflag_remake=0
			else
				echo "Failed creating new filesystem"
				_ctflag_remake=1
			fi
		fi
	else
		echo "Failed unmounting workdir"
		_ctflag_remake=1
	fi
	export _ctflag_remake
}

_fetch_new_sys() {
	if _mount_sysfs "$1"; then
		_sys_archive="stage3-amd64-${_server_version}.tar.bz2"
		export _sys_archive

		if sync -aAXhq "${_act_user}@${_act_ser}/${_dist_dir}/${_sys_archive}"  "$1/"; then
			scp "${_act_user}@${_act_ser}/${_dist_dir}/${_sys_archive}.md5sum"  "$1/"
			scp "${_act_user}@${_act_ser}/${_dist_dir}/${_sys_archive}.gpg"  "$1/"
			echo "New system was fetched successfully"
			_ctflag_fetch=0
		else
			echo "Fetching new system FAILED"
			_ctflag_fetch=1
		fi
	else
		echo "Failed mounting ${SYSDEV} to $1"
		_ctflag_fetch=1
	fi
	export _ctflag_fetch
}

_verify_t() {
	_verify_md5sum() {
		(
			cd "$1"

			if md5sum -c "${_sys_archive}.md5sum"; then
				echo "PASS" > verify.info
			else
				echo "FAILED" > verify.info
			fi
		)
	}

	_verify_origin() {
		(
			cd "$1"

			if gpg --verify "${_sys_archive}.gpg"; then
				echo "PASS" > verify.info
			else
				echo "FAILED" > verify.info
			fi
		)
	}
	
	rm -f "$1/verify.info"

	_verify_origin "$1" 
	if _check_s "$1"; then
		echo "Image's authentication verified"
		_verify_md5sum
		if _check_s "$1"; then
			echo "Image's integrity is healthy"
			_ctflag_verify=0
		else
			echo "Image's integrity check failed"
			_ctflag_verify=1
		fi
	else
		echo "Failed to verify the authentication of the image"
		_ctflag_verify=1
	fi
	export _ctflag_verify
}

_check_s() {
	if [[ "$(cat "$1/verify.info")" == 'PASS' ]]; then
		rm -f "$1/verify.info"
		return 0
	elif [[ "$(cat "$1/verify.info")" == 'FAILED' ]]; then
		rm -f "$1/verify.info"
		return 1
	fi
}

_extract_sys() {
	(
		cd "$1"
		if tar xvjpf "$2" --xattrs --numeric-owner; then
			echo "PASS" > verify.info
		else
			echo "FAILED" > verify.info
		fi
	)
}

_shell() {
	echo -e "\e[33mCalling bash subshell\e[0m"
	sleep 2
	echo 'echo -e "\e[33mInside Subshell\e[0m"' >> /root/.bashrc
	echo 'echo -e "\e[33mExit to return back to parent\e[0m"' >> /root/.bashrc
	(clear; exec /bin/bash;)
	sed -i "/Inside Subshell/d" "/root/.bashrc"
	sed -i "/Exit to return back to parent/d" "/root/.bashrc"
	echo -e "\e[33mYou are back to parent\e[0m"
}

# CALL SHELL
_rescue_shell() {
	while true; do
		echo "$*"
		echo
		echo "Do you wish to call shell function and fix the issues manually?"
		echo "Answer Y/N "
		read -rp "Input :: <= " YN
		case "$YN" in
			[yY])
				chroot_master_loop "SHELL"
				break;;
			[nN])
				break;;
		esac
	done
}

# SUBSHELL LOOP FUNCTION, IT OFFERS
subshell_loop() {
	while true; do
		_shell
		echo "If you fixed the issue, say CONTINUE proceed"
		echo "You can answer SHELL to open shell again"
		echo "Answer? CONTINUE/SHELL: "
		read -rp "Input :: <= " AANS
		case "${AANS}" in
			CONTINUE	)
				LOOPVAR="EXITSHELL"
				break;;
			SHELL 		)
				LOOPVAR="SHELL"
				;;
			*			)
				;;
		esac
	done
}

# CONTROLLER LOOP FUNCTION
controller_master_loop() {
	[[ -z $(echo "$@") ]] && _print_info 3
	LOOPVAR="$1"
	while true; do
		case "${LOOPVAR}" in
			SHELL)
				subshell_loop;;
			EXITSHELL)
				break;;
				
		esac
	done
}
