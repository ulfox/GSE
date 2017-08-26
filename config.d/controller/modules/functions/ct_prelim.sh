#!/bin/bash

# Exit and print to stderr
die() {
	echo "$@" 1>&2 ; exit 1
}

_call_backup_switch() {
	_ctflag_switch=0
	export _ctflag_switch
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

	_server_version="$(cat "${CTCONFDIR}/version")"
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

	echo "Using fsck on $2"
	if fsck -y "$2" >/dev/null 2>&1; then
		echo "Filesystem looks healthy"
		_fscheck=0
	else
		echo "Filesystem appears corrupted"
		echo "Attempting to repair"
		if fsck -yf "$2"; then
			echo "Repair was successful"
			_fscheck=0
		else
			echo "Automatic repair failed"
			_fscheck=1
		fi
	fi

	if [[ "${_fscheck}" == 1 ]]; then
		_rescue_shell
	fi

	unset _fscheck

	if eval mount -t "$2" -o rw -L "$3" "$1"; then
		return 0
	else
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
	if rsync -aAXrhq --exclude={"/proc","/dev","/sys"} "/mnt/rfs/" "/mnt/bfs/"; then
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
		echo "Neither one of SYSFS or BACKUPFS appear to host a root system"
		_ctflag_setup=0
	elif [[ "${_rfs_check}" == 1 && "${_bfs_check}" == 0 ]]; then
		echo "SYSFS appears to be missing"
		_ctflag_setup=1
	elif [[ "${_rfs_check}" == 0 && "${_bfs_check}" == 1 ]]; then
		echo "BACKUPFS is missing, fixing..."
		_ctflag_setup=2
	fi

	export _ctflag_setup

	unset _rfs_check
	unset _bfs_check

	# SYNC SYSFS TO BACKUPFS
	if [[ "${_ctflag_setup}" == 2 ]]; then
		_sync_backupfs
	fi

	_unmount "/mnt/rfs"
	_unmount "/mnt/bfs"
	_unmount "/mnt/workdir"
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
}

# INTERACTIVE FUNCTION
# DISABLED BY DEFAULT, PROBABLY WILL BE REMOVED
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
				echo "Could not unmount target $1"
				return 1
			fi
			sleep 0.1
			((++k))
		done

	return 0

	fi
}