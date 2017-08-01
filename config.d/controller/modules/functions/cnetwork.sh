#!/bin/bash

# CALL NETWORK FUNCtiON
if _call_net; then
	# CALL ACTIVE SERVER DEFINITION FUNCTION
	_server_exp

	# SET NET FLAG TO 0 IF AN ACTIVE SERVER HAS BEEN SET, OTHERWISE SET TO 1
	if [[ -n "${_act_ser}" ]]; then
		_ctflag_net=0
	else
		_ctflag_net=1
	fi
	export _ctflag_net
fi

# CHECK NETWORK FLAG AND FETCH VERSION AND CONFIG.D DIRECTORY
if [[ "${_ctflag_net}" == 0 ]]; then
	# DEFINE BEST ACTIVE SERVER
	_server_exp

	# MOUNT SYSFS AS RW
	_mount_sysfs "/mnt/workdir"

	# SOURCES EXP
	_sources_exp

	# FETCH CONFIG.D
	_fetch_confd
	if [[ "$_ctflag_confd}" == 0 ]]; then
		# EXPORT NEW CONFIGS
		_bsu_dfs
	fi

	# MOUNT SYSFS AS RW
	_mount_sysfs "/mnt/workdir"
	# CHECK LOCAL VERSION OF SYSFS WITH SERVERS VERSION
	_check_version
fi
