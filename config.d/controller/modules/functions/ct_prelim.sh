#!/bin/bash

# Exit and print to stderr
die() {
	echo "$@" 1>&2 ; exit 1
}

_call_backup_switch() {
	_ctflag_switch=0
	export _ctflag_switch
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
				eval umount -l "$i"/* >/dev/null 2>&1
				eval umount -l "$i" >/dev/null 2>&1
			done < <(grep "$1" "/proc/mounts")
			
			if [[ -z $(grep "$1" "/proc/mounts") ]]; then
				break
			fi
	
			if [[ "$k" -ge 20 ]]; then
				echo "Could not unmount target $1"
				return 1
			fi

			((++k))
		done

	return 0

	fi
}