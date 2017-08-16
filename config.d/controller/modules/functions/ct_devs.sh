#!/bin/bash

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
	eval _SYID="$(grep "$1" "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $2 }')"
	
	case "${_SYID}" in
		BYID)
			# EXPORT SDX{Y} DEVICE FROM DEVICE ID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			_tmp_type="$(blkid "/dev/disk/by-id/${_tmp_id}" | awk -F 'UUID=' '{ print $2 }' | cut -d ' ' -f 1 | cut -d '"' -f 2)"
			eval "$2"="$(blkid | grep "${_tmp_type}" | awk -F ':' '{ print $1 }')"
			;;
		UUID)
			# EXPORT SDX{Y} DEVICE FROM UUID
			_tmp_id="$(grep "$1" "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
			eval "$2"="$(blkid | grep "${_tmp_id}" | awk -F ':' '{ print $1 }')"
			;;
		SDX)
			if ls "${_SYID}" >/dev/null 2>&1; then
				# SDX{Y} DEVICE
				eval "$2"="${_SYID}"
			else
				# SDX{Y} DEVICE
				_tmp_fs01="$(grep "$1" "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $3 }')"
				eval "$2"="${_tmp_fs01}"
				# THIS OPTION WILL BE USED TO IDENTIFY THE DEVICE.
				# IN SDX{Y} PARTITION IS MISSING, THE PROCESS WILL CREATE A NEW INTERFACE.
			fi
			;;
		*)
			echo "No local device matches $(blkid | grep "${_tmp_type}" | awk -F ':' '{ print $1 }')"
			return 1
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
		SYSDEV="$(blkid | grep "SYSFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_SYSLABEL}" == 1 ]]; then
		_case_id "SYSFS" "SYSDEV"
	fi

	if [[ "${_BOOTLABEL}" == 0 ]]; then
		BOOTDEV="$(blkid | grep "BOOTFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_BOOTLABEL}" == 1 ]]; then
		_case_id "BOOTFS" "BOOTDEV"
	fi

	if [[ "${_BACKUPLABEL}" == 0 ]]; then
		BACKUPDEV="$(blkid | grep "BACKUPFS" | awk -F ':' '{ print $1 }')"
	elif [[ "${_BACKUPLABEL}" == 1 ]]; then
		_case_id "BACKUPFS" "BACKUPDEV"
	fi

	if [[ "${_USERDATALABEL}" == 0 ]]; then
		USERDATADEV="$(blkid | grep "USERDATAFS" | awk -F ':' '{ print $1 }')"
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
	BOOTFS="$(grep BOOTFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BOOTFS

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(grep SYSFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export SYSFS

	# EXPORT THE BACKUP FILE SYSTEM TYPE
	BACKUPFS="$(grep BACKUPFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export BACKUPFS

	# EXPORT THE USERDATA FILE STSTEM TYPE
	USERDATAFS="$(grep USERDATAFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $5 }')"
	export USERDATAFS

	# EXPORT BOOT SIZE
	BOOTSFS="$(grep BOOTFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BOOTSFS

	# EXPORT SYSTEM SIZE
	SYSSFS="$(grep SYSFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export SYSSFS

	# EXPORT BACKUP SIZE
	BACKUPSFS="$(grep BACKUPFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export BACKUPSFS

	# EXPORT USERDATA SIZE
	USERDATASFS="$(grep USERDATAFS "${CTCONFDIR}/confdir/cdevname.info" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ' ' '{ print $4 }')"
	export USERDATASFS

	if [[ "${_ctflag_confd}" == 0 ]]; then
		_sources_exp
	fi
}

_create_interface() {
	_btrfs_subvols() {
		_create_subvol() {
			if btrfs subvolume create "$@"; then
				return 0
			else
				return 1
			fi
		}
			
		_check_subvol_entry() {
			if ! btrfs subvolume list -o "/mnt/workdir" | grep -q "$2"; then
				echo "Subvolume $2 is missing."
				echo "Creating subvolume $2 for ${_WRK_LABEL}"

				if _create_subvol "/mnt/workdir/$2"; then
					echo "Subvolume created successfully"
					return 0
				else
					echo "Failed creating subvolume"
					return 1
				fi
			else
				echo "Subvolume $2 for ${_WRK_LABEL} exists"
			fi
		}
		
		_check_subvol() {
			echo "LABEL FOR CHECKSUBVOL: ${_WRK_LABEL}"
			case "${_WRK_LABEL}" in
				_BOOTLABEL)
					_check_subvol_entry "/mnt/workdir" "bootfs";;
				_SYSLABEL)
					_check_subvol_entry "/mnt/workdir" "sysfs";;
				_BACKUPFS)
					_check_subvol_entry "/mnt/workdir" "backupfs";;
				_USERDATAFS)
					_check_subvol_entry "/mnt/workdir" "userdatafs"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent/local"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent/local/home"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent/local/data"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent/local/root"
					sleep 0.5
					_check_subvol_entry "/mnt/workdir" "userdatafs/persistent/local/config.d"
					;;
			esac
		}

		echo "Mounting-Remounting ${_WRK_LABEL}"
		if [[ -n "$(grep "/mnt/workdir" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
			_unmount "/mnt/workdir"
		fi

		if mount -t "${_WRK_FS}" -o rw "${_WRK_DEV}" "/mnt/workdir"; then
			echo "${_WRK_LABEL} mounted on /mnt/workdir"
			if _check_subvol "/mnt/workdir"; then
				return 0
			else
				return 1
			fi
		else
			echo "Could not mount {_WRK_LABEL} on /mnt/workdir"
			echo "Subvolumes for {_WRK_LABEL} can not be verified"
			return 1
		fi

		if [[ -n "$(grep "/mnt/workdir" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
			_unmount "/mnt/workdir"
		fi
	}

	_remake_x() {
		case "${_WRK_LABEL}" in
			_BOOTLABEL)
				_R_LABEL='BOOTFS';;
			_SYSLABEL)
				_R_LABEL='SYSFS';;
			_USERDATALABEL)
				_R_LABEL='USERDATAFS';;
			_BACKUPLABEL)
				_R_LABEL='BACKUPFS';;
		esac

		if [[ "${_WRK_FS}" == 'btrfs' ]]; then
			_opt_var="-f -L"
		else
			_opt_var="-L"
		fi
		
		if _remake "${_WRK_FS}" "${_opt_var}" "${_R_LABEL}" "${_WRK_DEV}"; then
			return 0
		else
			return 1
		fi

		unset _opt_var
	}

	_interface_x() {
		echo ${_WRK_PAR}
		echo ${_WRK_PAR_NUM}
		echo ${_WRK_SFS}
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
				wipefs "${_WRK_PAR}"
				if echo -e "g\nn\n${_WRK_PAR_NUM}\n\n+${_WRK_SFS}\nw" | fdisk "${_WRK_PAR}"; then
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
		if [[ -n "${_WRK_DEV}" && -n "${_WRK_PAR}" && -n "${_WRK_PAR_NUM}" && -n "${_WRK_SFS}" && -n "${_WRK_FS}" ]]; then
			echo "Checking is {_WRK_PAR} has a disklabel"
			_disk_label_type="$(fdisk -l "${_WRK_PAR}" | grep 'Disklabel type:' | cut -d ' ' -f 3)"

			if [[ -n "${_disk_label_type}" ]]; then
				case "${_disk_label_type}" in
					gpt)
						_disklabel="gpt"
						;;
					dos)
						_disklabel="dos"
						;;
					*)
						echo "Disklabel format not supported by this scrip."
						return 1
						;;
				esac
			else
				echo "No disklabel detected on ${_WRK_PAR}"
				_disklabel="na"
			fi
			
			echo "Chaking if ${_WRK_PAR} holds any disk partitions"
			_disk_sub_parts=($(ls -1 ${_WRK_PAR} | grep "[0-9]"))

			if [[ -n "${_disk_sub_parts}" ]]; then
				echo "${_WRK_PAR} has no disklabel signature, neither hosts a partition"
				_disk_mark="clear"
			else
				echo "${_WRK_PAR} has no disklabel signature, neither hosts a partition"
				_disk_mark="notclear"
			fi
			
			if [[ -z "${_disk_label_type}" && ! -e "${_WRK_DEV}" ]]; then
				echo "${_WRK_DEV} is not configured"
				echo "Configuring..."

				if _interface_x "na"; then
					echo "${_WRK_DEV} created"
				else
					echo "Failed to creating ${_WRK_DEV}"
					return 1
				fi

			elif [[ -n "${_disk_label_type}" && ! -e "{_WRK_DEV}" ]]; then
				if _interface_x "${_disk_label_type}"; then
					echo "${_WRK_DEV} created"
				else
					echo "Failed to configure ${_WRK_DEV}"
					return 1
				fi
			elif [[ -n "${_disk_label_type}" && -e "{_WRK_DEV}" ]]; then
				echo "${_WRK_DEV} is already configured"
			fi
		else
			echo "Device is not set"
			return 1
		fi	
		
		_tmp_cfs="$(blkid /dev/sdc1 | grep "TYPE=\"${_WRK_FS}\"")"

		if [[ -z "${_tmp_cfs}" ]]; then
			echo "Creating ${_WRK_FS} files system on {_WRK_DEV}"
			if _remake_x; then
				echo "${_WRK_FS} file system created on ${_WRK_DEV} with ${_R_LABEL} label"
			else
				echo "Failed creating ${_WRK_FS} filesystem on ${_WRK_DEV}"
				return 1
			fi
		fi

		if [[ "${_WRK_FS}" == 'btrfs' ]]; then
			echo "Checking subvolume/s for ${_WRK_LABEL}"
			_btrfs_subvols "/mnt/workdir"
		fi

		unset _disk_label_type
		unset _tmp_cfs
	}

	for i in "BOOT" "SYS" "USERDATA" "BACKUP"; do
		_TMP_WRKDEV="${i}DEV"
		_WRK_DEV="${!_TMP_WRKDEV}"
		
		_TMP_WRKFS="${i}FS"
		_WRK_FS="${!_TMP_WRKFS}"
		
		_TMP_WRKSFS="${i}SFS"
		_WRK_SFS="${!_TMP_WRKSFS}"
		
		_TMP_PARDEV="_PAR_${_TMP_WRKDEV}"
		_WRK_PAR="${!_TMP_PARDEV}"
		
		_TMP_PARDEV_NUM="_PAR_NUM_${_TMP_WRKDEV}"
		_WRK_PAR_NUM="${!_TMP_PARDEV_NUM}"
		
		_TMP_LABEL="_${i}LABEL"
		_WRK_LABEL="_${i}LABEL"
		_WRK_LABEL_CON="${!_TMP_LABEL}"

		export _WRK_PAR_NUM
		export _WRK_PAR
		export _WRK_SFS
		export _WRK_FS
		export _WRK_DEV
		export _WRK_LABEL
		export _WRK_LABEL_CON

		echo "Checking $i"
		if [[ "${_WRK_LABEL_CON}" == 1 ]]; then
			echo "LABEL: ${_WRK_LABEL}"
			if _check_drv_condition "$i"; then
				echo "${_WRK_LABEL} has been configured"
				echo "Proceeding..."
				sleep 1
			else
				echo "Failed configuring ${_WRK_LABEL}"
				return 1
			fi
		elif [[ "${_WRK_LABEL_CON}" == 0 ]]; then
			echo "$i is already configured"
		elif [[ -z "${_WRK_LABEL_CON}" ]]; then
			echo "Dvice label condtion habe not been exported."
			echo "Can not proceed."
			return 1
		fi
	done

	unset _TMP_LABEL
	unset _TMP_PARDEV_NUM
	unset _TMP_PARDEV
	unset _TMP_WRKSFS
	unset _TMP_WRKFS
	unset _TMP_WRKDEV
}