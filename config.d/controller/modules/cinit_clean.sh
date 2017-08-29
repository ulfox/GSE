# EXPORT CONTROLLER CONFDIR
CTCONFDIR=/config.d
export CTCONFDIR
# EXPORT LOCAL SCRIPTDIR
CTSCRIPTS=/usr/local/controller
export CTSCRIPTS
# UPDATE PATH
export "PATH=${PATH}:/usr/local/controller"
# CONTROLLER PRELIMINARY FUNCTIONS
source "${CTSCRIPTS}/ct_prelim.sh"

if [[ "${_ctflag_setup}" == 0 || "${_ctflag_extract}" == 0 || "${_sys_config}" == 0 ]]; then
	if [[ -z "${_sys_archive}" ]]; then
		if [[ -z "${_server_version}" ]]; then
			_server_version="$(cat "${CTCONFDIR}/version")"
		fi

		_sys_archive="stage3-amd64-${_server_version}.tar.bz2"
	fi

	mount -L "SYSFS" "/mnt/workdir"

	if [[ "${_ctflag_extract}" == 0 ]]; then
		rm -f "/mnt/workdir/${_sys_archive}"
		rm -f "/mnt/workdir/${_sys_archive}.md5sum"
		rm -f "/mnt/workdir/${_sys_archive}.sig"
	fi

	if [[ "${_sys_config}" == 0 ]]; then
		rm -rf "/mnt/workdir/var/tmp/ctworkdir"
	fi

	umount "/mnt/workdir"
fi


