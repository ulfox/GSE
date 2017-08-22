#!/bin/bash

# NET FUNCTIONS
source "${CTSCRIPTS}/ct_netf.sh"

# EXPORT SERVER
_server_exp

# CHECK IF NETSELECT OR CUSTOM NET SCRIPT HAS MANAGED TO DEFINE A SERVER
if _check_net; then
	# SET NET FLAG TO 0 IF AN ACTIVE SERVER HAS BEEN SET, OTHERWISE SET TO 1
	if [[ -n "${_ctserver}" ]]; then
		_ctflag_net=0
	else
		_ctflag_net=1
	fi
	export _ctflag_net
fi

