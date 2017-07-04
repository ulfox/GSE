#!/bin/bash

# EXPORT CONTROLLER CONFDIR
CTCONFDIR=/config.d
export CTCONFDIR

# EXPORT LOCAL SCRIPTDIR
CTSCRIPTS=/usr/local/controller
export CTSCRIPTS

# UPDATE PATH
export "PATH=${PATH}:/usr/local/controller"

# CONTROLLER FUNCTIONS
source "${CTSCRIPTS}/cfunctions.sh"

source "${CTSCRIPTS}/cnetwork.sh"

if [[ "${_ctflag_net}" ]]; then
	# SYNC CONF.D DIRECTORY FROM SERVER TO LOCAL
	rsync -aAXhrq "${_M_SERVER}/config.d/controller/" "${CTCONFDIR}/confdir/"
	
	# EXPORT NEW CONFIGS
	_bsu_dfs
	
	# COPY VERSION REGISTERED AS DEFAULT FROM THE SERVER
	if rsync -aAXhq "${_M_SERVER}/local/version"  "${CTCONFDIR}/version"; then
		if mount -t "${SYSFS}" -o rw "${SYSDEV}" "/mnt/workdir"; then
			_local_version="$(cat "/mnt/workdir/var/lib/version")"
			_server_version="$(cat "${CTCONFDIR}/version")"
			if [[ "${_local_version}" != "${_server_version}" ]]; then
				if [[ -z "${_ctflag_nohuman}" ]]; then
					echo "A new system version is present on the server"
					echo "Do you wish to fetch the new system?"
					while true; do
						echo "Answer: Y/N "
						read -rp "Input :: <= " ANS
							case "${ANS}" in
								[yY])
									if umount "/mnt/workdir"; then
										if [[ "${SYSFS}" == 'btrfs' ]]; then
											eval "mkfs.${SYSFS}" -L ROOTFS -f "${SYSDEV}"
										else
											eval "mkfs.${SYSFS}" -L ROOTFS "${SYSDEV}"
										fi
									else
										_rescue_shell "Could not umount ${SYSDEV} from /mnt/workdir"
									fi

									if mount -t "${SYSFS}" -o rw "${SYSDEV}" "/mnt/workdir"; then
										if sync -aAXhq "${_M_SERVER}/dist.d/stage3-amd64-${_server_version}.tar.bz2"  "${CTCONFDIR}/version"; then
											echo "New system was fetched successfully"
										else
											echo "Fetching new system FAILED"
										fi

		else
			_rescue_shell "Could not mount ${ROOTFS} to /mnt/workdir"
fi

# IF NETWORKING IS ESTABLISHED
# CHECK IF THERE ARE ANY CHANGES IN THE CONFIG.D DIRECTORY
# IF CHANGES EXIST
# FETCH CONFIG.D DIRECTORY
# EXPORT NEW CONFIG.D CONFIGURATIONS
# ASK FOR VERSION

# COMPARE LOCAL VERSION WITH THE FETCHED ONE
# IF THEY DONT MATCH OR IF THE LOCAL ONE IS MISSING
# PROMPT TO WIPE SYSFS
# CREATE NEW SYSFS
# FETCH NEW IMAGE FROM THE SERVER
# EXPORT THE IMAGE
