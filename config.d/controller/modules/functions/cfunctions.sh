#!/bin/bash

die() {
	echo "$@" 1>&2 ; exit 1
}

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

_case_id() {
	# EXPORT THE ID OPTION FOR THE TARGET
	eval _SYID="$(grep "$1" "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $2 }')"
	case "${_SYID}" in
		BYID)
			# EXPORT SDX{Y} DEVICE FROM DEVICE ID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			_tmp_type="$(blkid "/dev/disk/by-id/${_tmp_id}" | awk -F 'UUID=' '{ print $2 }' | cut -d ' ' -f 1 | cut -d '"' -f 2)"
			eval "$2"="$(blkid | grep "${_tmp_type}" | awk -F ':' '{ print $1 }')"
			;;
		UUID)
			# EXPORT SDX{Y} DEVICE FROM UUID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			eval "$2"="$(blkid | grep "${_tmp_id}" | awk -F ':' '{ print $1 }')"
			;;
		SDX)
			if ls "${_SYID}" >/dev/null 2>&1; then
				# SDX{Y} DEVICE
				eval "$2"="${_SYID}"
			else
				# SDX{Y} DEVICE
				_tmp_fs01="$(grep "$1" "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
				eval "$2"="${_tmp_fs01}"
				# THIS OPTION WILL BE USED TO IDENTIFY THE DEVICE.
				# IN SDX{Y} PARTITION IS MISSING, THE PROCESS WILL CREATE A NEW INTERFACE.
			fi
			;;
	esac
	
	unset _tmp_fs01
	unset _tmp_i
	unset _tmp_type
}

_scan_id_ty() {
	# CHECK IF { SYSFS, BOOTFS, BACKUPFS, USERDATAFS } LABELS EXIST
	_a_priori_devices

	# EXPORT SDX{Y} FOR SYSFS/BOOTFS/BACKUPFS/USERDATAFS
	if [[ "${_SYSLABEL}" == 0 ]]; then
		SYSDEV="$(blkid | grep "SYSFS" | awk -f ':' '{ print $1 }')"
	elif [[ "${_SYSLABEL}" == 1 ]]; then
		_case_id "SYSFS" "SYSDEV"
	fi

	if [[ "${_BOOTLABEL}" == 0 ]]; then
		SYSDEV="$(blkid | grep "BOOTFS" | awk -f ':' '{ print $1 }')"
	elif [[ "${_BOOTLABEL}" == 1 ]]; then
		_case_id "BOOTFS" "BOOTDEV"
	fi

	if [[ "${_BACKUPLABEL}" == 0 ]]; then
		SYSDEV="$(blkid | grep "BACKUPFS" | awk -f ':' '{ print $1 }')"
	elif [[ "${_BACKUPLABEL}" == 1 ]]; then
		_case_id "BACKUPFS" "BACKUPDEV"
	fi

	if [[ "${_USERDATALABEL}" == 0 ]]; then
		SYSDEV="$(blkid | grep "USERDATAFS" | awk -f ':' '{ print $1 }')"
	elif [[ "${_USERDATALABEL}" == 1 ]]; then
		_case_id "USERDATAFS" "USERDATADEV"
	fi

	eval "_PAR_BOOTDEV"="$(echo "${BOOTDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_BOOTDEV"="${BOOTDEV: -1}"

	eval "_PAR_SYSDEV"="$(echo "${SYSDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_SYSDEV"="${SYSDEV: -1}"

	eval "_PAR_BACKUPDEV"="$(echo "${BACKUPDEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_BACKUPDEV"="${BACKUPDEV: -1}"

	eval "_PAR_USERDATADEV"="$(echo "${USERDATADEV}" | sed 's/[!0-9]//g')"
	eval "_PAR_NUM_USERDATADEV"="${USERDATADEV: -1}"
}

_bsu_dfs() {
	_scan_id_ty "$@"

	export BOOTDEV
	export SYSDEV
	export BACKUPDEV
	export USERDATADEV

	# EXPORT THE BOOT FILE SYSTEM TYPE
	BOOTFS="$(grep BOOTFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BOOTFS

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(grep SYSFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export SYSFS

	# EXPORT THE BACKUP FILE SYSTEM TYPE
	BACKUPFS="$(grep BACKUPFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BACKUPFS

	# EXPORT THE USERDATA FILE STSTEM TYPE
	USERDATAFS="$(grep USERDATAFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export USERDATAFS

	# EXPORT BOOT SIZE
	BOOTSFS="$(grep BOOTFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BOOTSFS

	# EXPORT SYSTEM SIZE
	SYSSFS="$(grep SYSFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export SYSSFS

	# EXPORT BACKUP SIZE
	BACKUPSFS="$(grep BACKUPFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BACKUPSFS

	# EXPORT USERDATA SIZE
	USERDATASFS="$(grep USERDATAFS "${CTCONFDIR}/confdir/devname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export USERDATASFS

	if [[ "${_ctflag_confd}" == 0 ]]; then
		_sources_exp
	fi
}

_create_interface() {
	_remake_x() {
		if [[ "${_WRK_FS}" == 'btrfs' ]]; then	
			if _remake "${_WRK_FS}" "-f -L" "${_WRK_LABEL}" "${_WRK_DEV}"; then
				echo "${_WRK_FS} file system created on ${_WRK_DEV} with ${_WRK_LABEL} label"
				return 0
			else
				echo "Failed creating ${_WRK_FS} filesystem on ${_WRK_DEV}"
				return 1
			fi
		else
			if _remake "${_WRK_FS}" "-L" "${_WRK_LABEL}" "${_WRK_DEV}"; then
				echo "${_WRK_FS} file system created on ${_WRK_DEV} with ${_WRK_LABEL} label"
				return 0
			else
				echo "Failed creating ${_WRK_FS} filesystem on ${_WRK_DEV}"
				return 1
			fi
		fi
	}

	_interface_x() {
		case "$1" in
			dos)
				if echo -e "n\np\n${_WRK_PAR_NUM}\n\n+${_WRK_SFS}\nw" | fdisk "${_WRK_PAR}"; then
					return 0
				else
					return 1
				fi
				;;
			gpt)
				if echo -e "n\n${_WRK_PAR_NUM}\n\n+${_WRK_SFS}\nw" | fdisk "${_WRK_PAR}"; then
					return 0
				else
					return 1
				fi
				;;
			na)
				if echo -e "g\nn\n${_WRK_PAR_NUM}\n\n${_WRK_SFS}\nw" | fdisk "${_WRK_PAR}"; then
					return 0
				else
					return 1
				fi
				;;
			*)
				echo "Function: _interface_x: Something went wrong"
				return 1
				;;
		esac
	}

	_check_drv_condition() {
		if [[ "${_WRK_LABEL}" == 'USERDATA' && "${_NOUSERDATA}" == 0 ]]; then
			echo "Skipping userdata partition"
			return 0
		fi

		if [[ -n "${_WRK_LABEL}" ]]; then
			if [[ -n "${_WRK_DEV}" && -n "${_WRK_PAR}" && -n "${_WRK_PAR_NUM}" && -n "${_WRK_SFS}" && -n "${_WRK_FS}" ]]; then
				_disk_label_type="$(fdisk -l "${_WRK_PAR}" | grep 'Disklabel type:' | cut -d ' ' -f 3)"
				_disk_partition="$(blkid "${_WRK_DEV}")"
				
				if [[ -z "${_disk_label_type}" ]]; then
					if _interface_x "na"; then
						echo "${_WRK_DEV} created"
						if _remake_x; then
							return 0
						else
							return 1
						fi
					else
						echo "Failed to configure ${_WRK_DEV}"
						return 1
					fi
				elif [[ -n "${_disk_label_type}" && -z "${_disk_partition}" ]]; then
					if _interface_x "${_disk_label_type}"; then
						echo "${_WRK_DEV} created"
						if _remake_x; then
							return 0
						else
							return 1
						fi
					else
						echo "Failed to configure ${_WRK_DEV}"
						return 1
					fi
				elif [[ -n "${_disk_label_type}" && -n "${_disk_partition}" ]]; then
					if _remake_x; then
						return 0
					else
						return 1
					fi
				fi
			else
				echo "Device is not set"
				return 1
			fi
		fi
	}

	for i in "BOOT" "SYS" "USERDATA" "BACKUP"; do
		_TMP_WRKDEV="${i}DEV"
		_WRK_DEV="${!_TMP_WRKDEV}"
		export _WRK_DEV

		_TMP_WRKFS="${i}FS"
		_WRK_FS="${!_TMP_WRKFS}"
		export _WRK_FS

		_TMP_WRKSFS="${i}SFS"
		_WRK_SFS="${!_TMP_WRKSFS}"
		export _WRK_SFS

		_TMP_PARDEV="_PAR_${_TMP_WRKDEV}"
		_WRK_PAR="${!_TMP_PARDEV}"
		export _WRK_PAR

		_TMP_PARDEV_NUM="_PAR_NUM_${_TMP_WRKDEV}"
		_WRK_PAR_NUM="${!_TMP_PARDEV_NUM}"
		export _WRK_PAR_NUM

		_TMP_LABEL="_${i}LABEL"
		_WRK_LABEL="${!_TMP_LABEL}"

		echo "Checking $i"
		if _check_drv_condition "$i"; then
			echo "$i has been configured"
			return 0
		else
			echo "Failed configuring $i"
		fi
	done
}

_server_exp() {
	echo "Selecting server..."

	# CREATE AN ARRAY WHICH HOLDS THE SERVERS
	_ser_list=()
	# CREATE AN ARRAY WHICH HOLDS THE SERVERS AVERAGE LETENCIES
	_act_ser_ar=()
	
	# POPULATE THE ABOVE TWO ARRAYS
	while read -r s; do
		echo "Checking $s"
		# DROP AN ENTRY IF PING FAILS
		if ping -c 1 "$s" >/dev/null 2>&1; then
			echo "Connection for $s is true"
			# GET AVERAGE LETENCY FROM 3 PING ACTIONS ON THE ENTRY
			avms=$(ping -c 3 "$s" | tail -1 | awk -F '/' '{print $5}')
			if [[ -n "${avms}" ]]; then
				# SET THE SERVER THAT COULD BE PINGED
				_ser_list+=("${s}")
				# SET THE AVERAGE LETENCY FOR THE ABOVE SERVER AS 1:1
				_act_ser_ar+=("${avms}")
			else
				# SKIP ENTRY
				echo "Could not get average value for $i"
				echo "Rejecting this entry"
			fi
		else
			# SKIP ENTRY
			echo "Connection with $s could not be established"
			echo "Rejecting this entry"
		fi

	done < <(cat ${CTCONFDIR}/sources/servers | sed '/^#/ d' | sed '/^\s*$/d')

	# EXPORT SERVER ARRAY SIZE -1
	# WE SUBSTRACT -1 BECAUSE ARRAYS START FROM 0 ENTRY
	_tmp_var_ms="$(( ${#_ser_list[@]} - 1 ))"
	
	# SET MINIMUM MS AS THE FIRST ENTRY
	_min_ms="${_act_ser_ar[0]}"

	# COMPARE THE ENTRIES AND KEEP THE MINIMUM
	for i in $(eval echo "{0..${_tmp_var_ms}}"); do
		 if ((${_act_ser_ar[$i]%.*} <= ${_min_ms%.*})); then
		 	_min_ms="${_act_ser_ar[$i]%.*}"
		 	_act_ser="${_ser_list[$i]}"
		 fi
	done

	# THE ACTIVE SERVER _ACT_SER IS THE ENTRY WHICH HAD THE LOWEST MS FROM THE 1:1 MS ARRAY
	echo "Most effective server is: ${_act_ser} with average ms: ${_min_ms}"

	unset _tmp_var_ms
	unset _min_ms
	unset _ser_list
	unset _act_ser_ar
	unset avms
}

_sources_exp() {
	# SOURCE THE SOURCES CONFIGURATION FILES FOR EXPORTING THE SERVER INFORMATIONS
	source "${CTCONFDIR}/confdir/sources/sources.conf"

	# THIS PATH INDICATES THE LOCATION OF THE CONFIG.D DIRECTORY ON THE SERVER SIDE. EXAMPLE: /home/user1/gse/config.d
	if [[ -z "${_conf_dir}" ]]; then
		_conf_dir="$(grep "confdir" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _conf_dir
	fi

	# THIS PATH INDICATES THE LOCATION OF THE DIST.D DIRECTORY. SEE CONFDIR EXAMPLE
	if [[ -z "${_dist_dir}" ]]; then
		_dist_dir="$(grep "distdir" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _dist_dir
	fi

	# THIS VARIABLE IS THE USER THAT WILL BE USED FOR THE CONNECTION BETWEEN THE HOST AND THE SERVER.
	if [[ -z "${_ser_user}" ]]; then
		_ser_user="$(grep "user" "${CTCONFDIR}/confdir/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
		export _ser_user
	fi
}

_call_net() {
	# CALL A SIMPLE DHPCD BUSYBOX NETWORK FUNCTION
	if grep -q "ip=dhcp" "/proc/cmdline"; then
		ifconfig "${_net_interface}" up
		busybox udhcpc -t 5 -q -s "/bin/net_script.sh"
	fi

	# HERE WILL BE ADDED A CUSTOM NETWORK FUNCTION
	# MEANING THAT INSTEAD OF RUNNING THE ABOVE DHCP NET FUNCTION
	# ONE WILL BE ABLE TO SOURCE HIS OWN NETWORKING SCRIPT.
}

# MOUNT SYSTEM
_mount_sysfs() {
	# IF MOUNT, THEN REMOUNT
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

	if mount -t "${SYSFS}" -o rw "${SYSDEV}" "$1"; then
		return 0
	else
		return 1
	fi
}

# THIS FUNCTION CHANGES THE BOOTFLAG FROM SYSFS TO BACKUP
# LATER ON, THIS DEVICE WILL REPLACE THE CURRENT DEVICE HOSTING THE SYSTEM.
_call_backup_switch() {
	_ctflag_bootflag="BACKUP"
	export _ctflag_bootflag
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

# FETCH THE DEFAULT VERSION FROM THE SERVER
_fetch_version() {
	if scp "${_act_user}@${_act_ser}/${_dist_dir}" "${CTCONFDIR}/version"; then
		_ctflag_sverison=0
	else
		_ctflag_sversion=1
	fi
	export _ctflag_sversion
}

# FETCH NEW CONFIG.D DIRECTORY
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
	fi
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

_remake() {
	if eval "mkfs.$1" "$2" "$3" "$4"; then
		return 0
	else
		return 1
	fi
}

_remake_sysfs() {
	if _unmount "$1"; then
		if [[ "${SYSFS}" == 'btrfs' ]]; then
			if _remake "${SYSFS}" "-f -L" "SYSFS" "${SYSDEV}"; then
				echo "File system created"
				_ctflag_remake=0
			else
				echo "Failed creating new filesystem"
				_ctflag_remake=1
			fi
		else
			if _remake "${SYSFS}" "-L" "SYSFS" "${SYSDEV}"; then
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

_call_tmpfs() {
	_other_points() {
		mkdir -p "$NEWROOT/.var"
		mkdir -p "$NEWROOT/.tmp"
		mount -t tmpfs -o size=2G tmpfs "$NEWROOT/.var"
		mount -t tmpfs -o size=5G tmpfs "$NEWROOT/.tmp"
		rsync -aAXPhrv "$NEWROOT/var/" "$NEWROOT/.var" >/dev/null 2>&1
		rsync -aAXPhrv "$NEWROOT/tmp/" "$NEWROOT/.tmp" >/dev/null 2>&1
		mount --move "$NEWROOT/.var" "$NEWROOT/var"
		mount --move "$NEWROOT/.tmp" "$NEWROOT/tmp"
	}

	mkdir -p "$NEWROOT/.etc"
	mount -t tmpfs tmpfs "$NEWROOT/.etc"
	rsync -aAXPhrv "$NEWROOT/etc/" "$NEWROOT/.etc" >/dev/null 2>&1
	mount --move "$NEWROOT/.etc" "$NEWROOT/etc"
}
