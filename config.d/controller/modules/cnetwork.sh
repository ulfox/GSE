#!/bin/bash

# SIMPLE DHCP NETWORKING
if _call_net; then
	_ctflag_net=0
	export _ctflag_net
fi

# CONFIG.D LOCATION
# DIST.D LOCATION

# CHECK NETWORK FLAG AND FETCH VERSION AND CONFIG.D DIRECTORY
if [[ "${_ctflag_net}" ]]; then
	# DEFINE BEST ACTIVE SERVER
	_server_exp

	# SOURCES EXP
	_sources_exp

	# FETCH CONFIG.D
	_fetch_confd
	if [[ "$_ctflag_confd}" == 0 ]]; then
		# EXPORT NEW CONFIGS
		_bsu_dfs
	fi

	# MOUNT SYSFS AS RO
	_mount_sysfs
	# CHECK LOCAL VERSION OF SYSFS WITH SERVERS VERSION
	_check_version
fi