#!/bin/bash

# MOUNT SYSTEM
_mount_sysfs() {
	# IF MOUNT, THEN REMOUNT
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

	echo -e "[\e[34m*\e[0m] Using fsck on ${SYSDEV}"
	if fsck -y "${SYSDEV}" >/dev/null 2>&1; then
		echo -e "[\e[32m*\e[0m] Filesystem looks healthy"
		_fscheck=0
	else
		echo -e "[\e[33m*\e[0m] Filesystem appears corrupted"
		echo -e "[\e[34m*\e[0m] Attempting to repair"
		if fsck -yf "${SYSDEV}"; then
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

	echo -e "[\e[34m*\e[0m] Attempting to mount ${SYSDEV} at $1"
	if eval mount -t "${SYSFS}" -o rw -L "SYSFS" "$1"; then
		echo -e "[\e[32m*\e[0m] Mounted successfully"
		return 0
	else
		echo -e "[\e[31m*\e[0m] Failed mounting"
		return 1
	fi
}

# FETCH THE DEFAULT VERSION FROM THE SERVER
_fetch_version() {
	if scp "${_ser_user}@${_ctserver}:${_dist_dir}/latest_stage" "${CTCONFDIR}/version"; then
		_ctversion=0
	else
		_ctversion=1
	fi
	export _ctversion
}

# FETCH NEW CONFIG.D DIRECTORY
_fetch_confd() {
	echo -e "[\e[34m*\e[0m] Syncing confdir from server"
	if [[ -n "$(rsync -aAPhrcn "${_ser_user}@${_ctserver}:${_conf_dir}/controller/modules/files/" "${CTCONFDIR}/confdir/" --delete | sed '/receiving incremental file list/d')" ]]; then
		if rsync -aAPhrqc "${_ser_user}@${_ctserver}:${_conf_dir}/controller/modules/files/" "${CTCONFDIR}/confdir/" --delete; then
			echo -e "[\e[32m*\e[0m] Sync was successful"
			echo -e "[\e[34m*\e[0m] Syncing new confdir to storage"

			mount -t "${BOOTFS}" -o rw "${BOOTDEV}" "/mnt/log"

			if rsync -aAPhqrc "${CTCONFDIR}/confdir" "/mnt/log/" --delete; then
				echo -e "[\e[32m*\e[0m] Synced"
				sync;sync
			else
				echo -e "[\e[33m*\e[0m] Failed"
			fi
		
			umount -l "/mnt/log"
		
			_ctflag_confd=0
		else
			_ctflag_confd=1
		fi
	else
		echo -e "[\e[35m*\e[0m] No changes detected"
		_ctflag_confd=1
	fi
	export _ctflag_confd
}

_check_version() {
	if [[ "${_ctversion}" == 0 ]]; then
		_server_version="$(cat "${CTCONFDIR}/version")"
		if [[ -e "/mnt/workdir/var/lib/gse/version" ]]; then
			_local_version="$(cat "/mnt/workdir/var/lib/gse/version")"
			if [[ "${_local_version}" != "${_server_version}" ]]; then
				if [[ -n "${_ctflag_human}" ]]; then
					if _question "A new System Version is present on the server" "Do you wish to fetch the new system?"; then
						_ctflag_sysfetch=0
					else
						_ctflag_sysfetch=1
					fi
				else
					echo -e "[\e[33m*\e[0m] Remote version does not matches local"
					_ctflag_sysfetch=0
				fi
			else
				echo -e "[\e[35m*\e[0m] Remote version matches the local"
				_ctflag_sysfetch=1
			fi
		elif [[ ! -e "/mnt/workdir/var/lib/gse/version" ]]; then
			echo -e "[\e[31m*\e[0m] System is corrupted"
			_ctflag_sysfetch=9
		fi
	export _ctflag_sysfetch
	fi
}

_fetch_new_sys() {
	if _mount_sysfs "$1"; then
		_sys_archive="stage3-amd64-${_server_version}.tar.bz2"
		export _sys_archive

		if scp "${_ser_user}@${_ctserver}:${_dist_dir}/${_sys_archive}"  "$1/"; then
			scp "${_ser_user}@${_ctserver}:${_dist_dir}/${_sys_archive}.md5sum"  "$1/"
			#scp "${_ser_user}@${_ctserver}:${_dist_dir}/${_sys_archive}.sig"  "$1/"
			echo -e "[\e[32m*\e[0m] New system was fetched successfully"
			_ctflag_fetch=0
		else
			echo -e "[\e[31m*\e[0m] Fetching new system FAILED"
			_ctflag_fetch=1
		fi
	else
		echo -e "[\e[31m*\e[0m] Failed mounting ${SYSDEV} to $1"
		_ctflag_fetch=1
	fi
	export _ctflag_fetch
}

_verify_target() {
	_verify_md5sum() {
		(
			cd "$1"

			if md5sum -c "${_sys_archive}.md5sum"; then
				echo "PASS" > "/tmp/verify.info"
			else
				echo "FAILED" > "/tmp/verify.info"
			fi
		)
	}
	
	_verify_origin() {
		(
			cd "$1"

			if _gpg_verify "${_sys_archive}.sig" "${_sys_archive}"; then
				echo "PASS" > "/tmp/verify.info"
			else
				echo "FAILED" > "/tmp/verify.info"
			fi
		)
	}

	_check_last() {
		if [[ "$(cat "/tmp/verify.info")" == 'PASS' ]]; then
			rm -f "/tmp/verify.info"
			return 0
		elif [[ "$(cat "/tmp/verify.info")" == 'FAILED' ]]; then
			rm -f "/tmp/verify.info"
			return 1
		fi
	}
	
	rm -f "/tmp/verify.info"

	#_verify_origin "$1"

	_md5_check() {
		_verify_md5sum "$1"
		if _check_last; then
			_ctflag_verify=0
			return 0
		else
			_ctflag_verify=1
			return 1
		fi
	}

	_restricted() {
		if _check_last; then
			echo -e "[\e[35m*\e[0m] Origin verified"
			_md5_check "$1"
		else
			if [[ ! -e "${CTSCRIPTS}/gpg/gpg_pub" ]]; then
				echo -e "[\e[33m*\e[0m] No gpg key found!"
				_md5_check "$1"
			elif [[ -e "${CTSCRIPTS}/gpg/gpg_pub" ]]; then
				echo -e "[\e[31m*\e[0m] Failed to verify the authentication of the image"
				_ctflag_verify=1
			fi
		fi
	}
	
	if _md5_check "$1"; then
		echo -e "[\e[35m*\e[0m] Integrity verified"
	else
		echo -e "[\e[33m*\e[0m] Integrity check failed"
	fi
	export _ctflag_verify
}

_extract_sys() {
	(
		cd "$1"
		_e_report_back "Extracting system tarball..."
		if tar xvjpf "$2" --xattrs --numeric-owner >/dev/null; then
			echo -e "[\e[32m*\e[0m] Extracted"
			echo "PASS" > "/tmp/verify.info"
		else
			echo -e "[\e[31m*\e[0m] An error occured"
			echo "FAILED" > "/tmp/verify.info"
		fi
	)
}



