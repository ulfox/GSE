#!/bin/bash

# Exit and print to stderr
die() {
	echo "$@" 1>&2 ; exit 1
}

_call_backup_switch() {
	if [[ "${_ctflag_bconf}" != 0 && "${_ctflag_setup}" != 0 ]]; then
		_ctflag_switch=0
		export _ctflag_switch
	else
		echo -e "[\e[31m*\e[0m] Switch to backup is called but there is no backup"
		_rescue_shell "Switch to backup is called but there is no backup"
		# exit 1
	fi
}

_gpg_import() {
	gpg --import "/usr/local/controller/gpg/gpg_pub" >/dev/null 2>&1
}

_gpg_verify() {
	if gpg --verify "$1" "$2"; then
		return 0
	else
		return 1
	fi
}

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

	BOOTFS="$(blkid "${BOOTDEV}" | awk -F ' ' '{print $4}' | sed 's/TYPE=//g' | sed 's/"//g')"
	USERDATAFS="$(blkid "${USERDATADEV}" | awk -F ' ' '{print $4}' | sed 's/TYPE=//g' | sed 's/"//g')"
	export BOOTFS
	export USERDATAFS

	_server_version="$(cat "${CTCONFDIR}/version")"

	if [[ -n "${BOOTFS}" ]]; then
		mkdir -p "/mnt/log"
		mount -t "${BOOTFS}" -o rw "${BOOTDEV}" "/mnt/log"
	
		if [[ -e "/mnt/log/confdir" ]]; then
			echo -e "[\e[34m*\e[0m] Updating confdir from local storage"
		
			if rsync -aAPrhqc "/mnt/log/confdir" "${CTCONFDIR}/" --delete; then
				sync;sync
				echo -e "[\e[32m*\e[0m] Updated"
			else
				echo -e "[\e[31m*\e[0m] Failed"
			fi
		fi

		umount -l "/mnt/log"
	else
		echo -e "[\e[33m*\e[0m] WARNING: BOOTFS has not been defined"
	fi

	if [[ -n "${USERDATAFS}" ]]; then
		: # TBU
	else
		echo -e "[\e[33m*\e[0m] WARNING: USERDATAFS has not been defined"
	fi
}

_unmount_all_targets() {
	_unmount "/mnt/workdir"
	_unmount "/mnt/bfs"
	_unmount "/mnt/rfs"
}

_e_report_back() {
	echo -e "\e[33m$*\e[0m" 1>&2
}

_o_report_back() {
	echo -e "\e[34m$*\e[0m" 1>&2	
}

pass() {
	echo -e "[\e[34m$@\e[0m]"
}

# CHECK IF LABELS EXIST
_a_priori_devices() {
	if [[ -e "/dev/disk/by-label/SYSFS" ]]; then
		_SYSLABEL=0
	else
		_SYSLABEL=1
	fi

	export _SYSLABEL

	if [[ -e "/dev/disk/by-label/BOOTFS" ]]; then
		_BOOTLABEL=0
	else
		_BOOTLABEL=1
	fi

	export _BOOTLABEL

	if [[ -e "/dev/disk/by-label/BACKUPFS" ]]; then
		_BACKUPLABEL=0
	else
		_BACKUPLABEL=1
	fi

	export _BACKUPLABEL

	if [[ -e "/dev/disk/by-label/USERDATAFS" ]]; then
		_USERDATALABEL=0
		_NOUSERDATA=0
	else
		_USERDATALABEL=1
		_NOUSERDATA=1
	fi

	export _NOUSERDATA
	export _USERDATALABEL
}

# MOUNT TARGET
_mount_target() {
	# IF MOUNT, THEN REMOUNT
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

	echo -e "[\e[34m*\e[0m] Using fsck on $2"
	if fsck -y "$2" >/dev/null 2>&1; then
		echo -e "[\e[32m*\e[0m] Filesystem looks healthy"
		_fscheck=0
	else
		echo -e "[\e[33m*\e[0m] Filesystem appears corrupted"
		echo -e "[\e[34m*\e[0m] Attempting to repair"
		if fsck -yf "$2"; then
			echo -e "[\e[32m*\e[0m] Repair was successful"
			_fscheck=0
		else
			echo -e "[\e[31m*\e[0m] Automatic repair failed"
			_fscheck=1
		fi
	fi

	if [[ "${_fscheck}" == 1 ]]; then
		_rescue_shell
	fi

	unset _fscheck

	echo -e "[\e[34m*\e[0m] Attempting to mount $3 at $1"
	if eval mount -t "$2" -o rw -L "$3" "$1"; then
		echo -e "[\e[32m*\e[0m] Mounted successfully"
		return 0
	else
		echo -e "[\e[31m*\e[0m] Failed mounting"
		return 1
	fi
}

_mount_pseudos() {
	for i in "dev" "sys" "proc"; do
		if [[ ! -e "$1/$i" ]]; then
			return 1
		fi
	done

	if ! mount -t proc /proc "$1/proc"; then
		return 1
	fi

	for i in "dev" "sys"; do
		if ! mount --rbind "/$i" "$1/$i"; then
			return 1
		fi
	done

	for i in "dev" "sys"; do
		if ! mount --make-rslave "$1/$i"; then
			return 1
		fi
	done
}

_sync_backupfs() {
	if rsync -aAXrhqc --exclude={"/proc","/dev","/sys"} "/mnt/rfs/" "/mnt/bfs/" --delete; then
		mkdir -p "/mnt/bfs/proc"
		mkdir -p "/mnt/bfs/sys"
		mkdir -p "/mnt/bfs/dev"

		return 0
	else
		return 1
	fi
}

_check_rbfs() {
	if _mount_target "/mnt/rfs" "${SYSFS}" "SYSFS"; then
		if _mount_pseudos "/mnt/rfs"; then
			cp "/usr/local/controller/check_con.sh" "/mnt/rfs/"
			chmod +x "/mnt/rfs/check_con.sh"
			if chroot "/mnt/rfs" "/check_con.sh"; then
				_rfs_check=0
			else
				_rfs_check=1
			fi
		else
			_rfs_check=1
		fi
	else
		_rescue_shell "Could not mount ${SYSDEV}"
	fi

	if _mount_target "/mnt/bfs" "${BACKUPFS}" "BACKUPFS"; then
		if _mount_pseudos "/mnt/bfs"; then
			cp "/usr/local/controller/check_con.sh" "/mnt/bfs/"
			chmod +x "/mnt/bfs/check_con.sh"
			if chroot "/mnt/bfs" "/check_con.sh"; then
				_bfs_check=0
			else
				_bfs_check=1
			fi
		else
			_bfs_check=1
		fi
	else
		_rescue_shell "Could not mount ${BACKUPDEV}"
	fi

	unset _ctflag_setup

	if [[ "${_rfs_check}" == 1 && "${_bfs_check}" == 1 ]]; then
		echo -e "[\e[33m*\e[0m] Neither one of SYSFS or BACKUPFS appear to host a root system"
		_ctflag_setup=0
	elif [[ "${_rfs_check}" == 1 && "${_bfs_check}" == 0 ]]; then
		echo -e "[\e[33m*\e[0m] SYSFS appears to be missing"
		_ctflag_setup=1
	elif [[ "${_rfs_check}" == 0 && "${_bfs_check}" == 1 ]]; then
		echo -e "[\e[33m*\e[0m] BACKUPFS is missing, fixing..."
		_ctflag_setup=2
	else
		echo -e "[\e[34m*\e[0m] Both SYSFS and BACKUPFS appear to host a root system"
		_ctflag_setup=3
	fi

	export _ctflag_setup

	unset _rfs_check
	unset _bfs_check

	_unmount "/mnt/rfs"
	_unmount "/mnt/bfs"
	_unmount "/mnt/workdir"
}

_sync_targets() {
	_mount_target "/mnt/rfs" "${SYSFS}" "SYSFS"
	_mount_target "/mnt/bfs" "${BACKUPFS}" "BACKUPFS"

	_sync_backupfs

	_unmount "/mnt/rfs"
	_unmount "/mnt/bfs"
}

_unset_ct() {
	unset _ctflag_switch
	unset _ctflag_net
	unset _ctflag_sysfetch
	unset _ctflag_setup
	unset _ctflag_extract
	unset _ctflag_bconf
	unset _ctflag_fetch
	unset _ctflag_verify
	unset _ctflag_remake
	unset _ctflag_confd
	unset _sys_config
	unset _sys_revert
	unset _check_sysver
}

# INTERACTIVE FUNCTION
# DISABLED BY DEFAULT, PROBABLY WILL BE REMOVED
_question() {
	for i in "$@"; do
		[[ "$i" ]] && _e_report_back "$i"
	done

	while true; do
		_e_report_back "Answer: Y/N "
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

_shell() {
	echo -e "\e[33mCalling bash subshell\e[0m"
	sleep 2
	echo 'echo -e "\e[33mInside Subshell\e[0m"' >> /root/.bashrc
	echo 'echo -e "\e[33mExit to return back to parent\e[0m"' >> /root/.bashrc
	(clear; exec /bin/bash && echo s;)
	sed -i "/Inside Subshell/d" "/root/.bashrc"
	sed -i "/Exit to return back to parent/d" "/root/.bashrc"
	echo -e "\e[33mYou are back to parent\e[0m"
}

# CALL SHELL
_rescue_shell() {
	while true; do
		for i in "$@"; do
			echo "$i"
		done

		_e_report_back "Do you wish to call shell function and fix the issues manually?"
		_e_report_back "Answer Y/N "
		read -rp "Input :: <= " YN
		case "$YN" in
			[yY])
				subshell_loop "SHELL"
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
		_e_report_back "If you fixed the issue, say CONTINUE proceed"
		_e_report_back "You can answer SHELL to open shell again"
		_e_report_back "Answer? CONTINUE/SHELL: "
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

# UNMOUNT TARGET
_unmount() {
	k=0
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		while true; do
			while read -r i; do
				if echo "$i" | grep -q "$1"; then
					eval umount -l "$i"/* >/dev/null 2>&1
					eval umount -l "$i" >/dev/null 2>&1
				fi
			done < "/proc/mounts"
			
			if [[ -z $(grep "$1" "/proc/mounts") ]]; then
				break
			fi
	
			if [[ "$k" -ge 20 ]]; then
				echo -e "[\e[31m*\e[0m] Could not unmount target $1"
				return 1
			fi
			sleep 0.1
			((++k))
		done

	return 0

	fi
}


