#!/bin/bash

# Export the sources.conf file
_sources_exp() {
	_ctserv_num="$(grep "${_ctserver}" "${CTCONFDIR}/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{print $1}')"
	_ctserv_num="${_ctserv_num:6:7}"
	
	# THIS PATH INDICATES THE LOCATION OF THE CONFIG.D DIRECTORY ON THE SERVER SIDE. EXAMPLE: /home/user1/gse/config.d
	_conf_dir="$(grep "confdir${_ctserv_num}" "${CTCONFDIR}/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
	export _conf_dir

	# THIS PATH INDICATES THE LOCATION OF THE DIST.D DIRECTORY. SEE CONFDIR EXAMPLE
	_dist_dir="$(grep "distdir${_ctserv_num}" "${CTCONFDIR}/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
	export _dist_dir

	# THIS VARIABLE IS THE USER THAT WILL BE USED FOR THE CONNECTION BETWEEN THE HOST AND THE SERVER.
	_ser_user="$(grep "user${_ctserv_num}" "${CTCONFDIR}/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{ print $2 }')"
	export _ser_user

	# EXPORT THE SYSTEM FILE SYSTEM TYPE
	SYSFS="$(blkid | grep "LABEL=\"SYSFS\"" | awk -F ' ' '{print $4}' | awk -F '=' '{print $2}' | sed 's/\"//g')"
	export SYS
}

_server_exp() {
	# Manual method in case one wishes to remove netselect for size or any other reason
	# MUCH SLOWER
	#
	_manual_check() {
		# CREATE AN ARRAY WHICH HOLDS THE SERVERS
		_ser_list=()
		# CREATE AN ARRAY WHICH HOLDS THE SERVERS AVERAGE LETENCIES
		_act_ser_ar=()
	
		# POPULATE THE ABOVE TWO ARRAYS
		while read -r s; do
			_e_report_back "Checking $s"
			# DROP AN ENTRY IF PING FAILS
			if ping -c 1 "$s" >/dev/null 2>&1; then
				echo -e "[\e[32m*\e[0m] Connection for $s is true"
				# GET AVERAGE LETENCY FROM 3 PING ACTIONS ON THE ENTRY
				avms=$(ping -c 3 "$s" | tail -1 | awk -F '/' '{print $5}')
				if [[ -n "${avms}" ]]; then
					# SET THE SERVER THAT COULD BE PINGED
					_ser_list+=("${s}")
					# SET THE AVERAGE LETENCY FOR THE ABOVE SERVER AS 1:1
					_act_ser_ar+=("${avms}")
				else
					# SKIP ENTRY
					echo -e "[\e[33m*\e[0m] Could not get average value for $i"
					_e_report_back "Rejecting this entry"
				fi
			else
				# SKIP ENTRY
				echo -e "[\e[33m*\e[0m] Connection with $s could not be established"
				echo -e "[\e[33m*\e[0m] Rejecting this entry"
			fi

		done < $(grep "server" "${CTCONFDIR}/sources/sources.conf" | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{print $2}')

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
		_o_report_back "Most effective server is: ${_act_ser} with average ms: ${_min_ms}"
		_ctserver="${_act_ser}"
		export _ctserver

		unset _act_ser
		unset _tmp_var_ms
		unset _min_ms
		unset _ser_list
		unset _act_ser_ar
		unset avms
	}

	echo -e "[\e[34m*\e[0m] Selecting server..."

	if [[ -e "/usr/bin/netselect" ]]; then
		_ser_tmp=()

		for i in $(cat ${CTCONFDIR}/sources.conf | grep server | sed '/^#/ d' | sed '/^\s*$/d' | awk -F ':' '{print $2}'); do
			_ser_tmp+=("$i")
		done

		_ser_list=()

		for i in $(netselect -v -t2 -s10 "${_ser_tmp[@]}" | awk -F ' ' '{print $2}'); do
			_ser_list+=("$i")
			_e_report_back "$i"
		done

		unset _ser_tmp

		_ctserver="${_ser_list[0]}"
	else
		_manual_check
	fi
}

_check_net() {
	if [[ -n "${_ctserver}" ]]; then
		return 0
	else
		if grep -q "net:0" "/usr/local/unet/udent_flag"; then
			# RE-SOURCE THE CUSTOM NET SCRIPT AND CHECK AGAIN
			echo -e "[\e[33m*\e[0m] Re-sourcing the custom net script"
			source "/usr/local/unet/unet.sh"
			_tmp_net_ct=0
			while true; do
				if ip a | grep -q "state UP"; then
					break
				fi
				
				((++_tmp_net_ct))
				sleep 1

				if [[ "${_tmp_net_ct}" -ge 10 ]]; then
					break
				fi
			done

			_server_exp
			
			if [[ "${_ctserver}" == '' ]]; then
				return 0
			else
				return 1
			fi
		else
			return 1
		fi
	fi
}



