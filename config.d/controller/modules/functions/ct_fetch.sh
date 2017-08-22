#!/bin/bash

_gpg_import() {
	gpg --import "/usr/local/controller/gpg/gpg_pub"
}

_gpg_verify() {
	if gpg --verify "$1" "$2"; then
		return 0
	else
		return 1
	fi
}

# MOUNT SYSTEM
_mount_sysfs() {
	# IF MOUNT, THEN REMOUNT
	if [[ -n "$(grep "$1" "/proc/mounts" | awk -F ' ' '{ print $2 }')" ]]; then
		_unmount "$1"
	fi

	if eval mount -t "${SYSFS}" -o rw -L "SYSFS" "$1"; then
		return 0
	else
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
	if rsync -aAPhrq "${_ser_user}@${_ctserver}:${_conf_dir}/" "${CTCONFDIR}/confdir/"; then
		_ctflag_confd=0
	else
		_ctflag_confd=1
	fi
	export _ctflag_confd
}

_check_version() {
	if [[ "${_ctversion}" == 0 ]]; then
		_local_version="$(cat "/mnt/workdir/var/lib/gse/version")"
		_server_version="$(cat "${CTCONFDIR}/version")"
		if [[ -e "/mnt/workdir/var/lib/gse/version" ]]; then
			if [[ "${_local_version}" != "${_server_version}" ]]; then
				if [[ -n "${_ctflag_human}" ]]; then
					if _question "A new System Version is present on the server" "Do you wish to fetch the new system?"; then
						_ctflag_sysfetch=0
					else
						_ctflag_sysfetch=1
					fi
				else
					echo "Remote version does not matches local"
					_ctflag_sysfetch=0
				fi
			else
				echo "Remote version matches the local"
				_ctflag_sysfetch=1
			fi
		else
			echo "System is corrupted"
			_ctflag_sysfetch=0
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
			scp "${_ser_user}@${_ctserver}:${_dist_dir}/${_sys_archive}.gpg"  "$1/"
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

			if _gpg_verify "${_sys_archive}.gpg" "${_sys_archive}"; then
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

	_verify_origin "$1"

	_md5_check() {
		_verify_md5sum "$1"
		if _check_last; then
			echo "Integrity verified"
			_ctflag_verify=0
		else
			echo "Image's integrity check failed"
			_ctflag_verify=1
		fi
	}

	if _check_last; then
		echo "Origin verified"
		_md5_check "$1"
	else
		if [[ ! -e "${CTSCRIPTS}/gpg/gpg_pub" ]]; then
			echo "No gpg key found!"
			_md5_check "$1"
		elif [[ -e "${CTSCRIPTS}/gpg/gpg_pub" ]]; then
			echo "Failed to verify the authentication of the image"
			_ctflag_verify=1
		fi
	fi
	export _ctflag_verify
}

_extract_sys() {
	(
		cd "$1"
		echo "Extracting tarbal..."
		if tar xvjpf "$2" --xattrs --numeric-owner >/dev/null; then
			echo "PASS" > "/tmp/verify.info"
		else
			echo "FAILED" > "/tmp/verify.info"
		fi
	)
}
