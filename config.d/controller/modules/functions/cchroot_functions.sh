#!/bin/bash

die() {
	echo "$@" 1>&2 ; exit 1
}
	
pass() {
	echo -e "[\e[34mDone\e[0m]"
}

_configure_timezone() {
	_timezone_set() {
		if emerge --config sys-libs/timezone-data | grep -q "invalid"; then
			if echo "UTC" >/etc/timezone; emerge --config sys-libs/timezone-data; then
				echo -e "[\e[32m*\e[0m] Resetting to UTC"
			else
				echo -e "[\e[31m*\e[0m] Resetting to UTC"
			fi
		fi
	}

	if [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		_state_save "/etc/timezone"
		source "${CHROOT_DIR}/ctimezone"
		if [[ "${TIMEZONE}" != TMZ ]]; then
			echo "${TIMEZONE}" > /etc/timezone && echo -e "[\e[32m*\e[0m] Configuring \e[34mTimezone\e[0m"
		else
			echo "UTC" > /etc/timezone && echo -e "[\e[32m*\e[0m] \e[34mConfiguring Timezone\e[0m"
		fi
		_timezone_set
	elif [[ "${_ctflag_chroot}" == 'revert' ]]; then
		cp "${CHROOT_DIR}/last_state/timezone" "/etc/timezone"
		_timezone_set
	fi 
}

_configure_locale() {
	if [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		_state_save "/etc/locale.gen"
		if [[ -z $(cat "${CHROOT_DIR}/clocale.gen" | sed '/^#/ d' | sed '/^\s*$/d') ]]; then
			sed -i '/en_US.UTF-8/d' /etc/locale.gen
		
			if echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; then
				echo -e "[\e[32m*\e[0m] Configuring [\e[34mlocale\e[0m]"
			else
				echo -e "[\e[31m*\e[0m] Configuring [\e[34mlocale\e[0m]"
			fi
		else
			echo "$(cat "${CHROOT_DIR}/clocale.gen")" > /etc/locale.gen
			sed -i '/en_US.UTF-8/d' /etc/locale.gen
		
			if echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; then
				echo -e "[\e[32m*\e[0m] Configuring \e[34mlocale\e[0m"
			else
				echo -e "[\e[31m*\e[0m] Configuring [\e[34mlocale\e[0m]"
			fi
		fi

		locale-gen
		export LC_ALL="en_US.UTF-8"
	
		SETLOC=$(eselect locale list | grep en_US | awk -F ' ' '{ print $1 }' \
		| awk -F '[' '{ print $2 }' | awk -F ']' '{ print $1 }')
		echo "${SETLOC}" > "${CHROOT_DIR}/last_state/SETLOC"

		if eselect locale set "${SETLOC}"; then
			echo -e "[\e[32m*\e[0m] Setting locale to [\e[34men_US\e[0m]" \
		else
			echo -e "[\e[31m*\e[0m] Failed setting locale to [\e[34men_US\e[0m]"
		fi
		unset SETLOC
	elif [[ "${_ctflag_chroot}" == 'revert' ]]; then
		cp "${CHROOT_DIR}/last_state/locale.gen" "/etc/locale.gen"
		locale-gen
		SETLOC="$(cat "${CHROOT_DIR}/last_state")"
		eselect locale set "${SETLOC}"
		unset SETLOC
	fi
}

_configure_fstab() {
	_state_save "/etc/fstab"
	if cat "${CHROOT_DIR}/cfstab" > /etc/fstab; then
		echo -e "[\e[32m*\e[0m] Creating [\e[34mfstab\e[0m] entries"
		if [[ -n $(cat "${CHROOT_DIR}/csystem_links" | sed '/^#/ d' | sed '/^\s*$/d') ]]; then
			BREAKVAR=0
			 while read -r i; do
				case $(echo "$i" | awk -F ' ' '{ print $1 }') in
					tmpfs)
						echo >> /etc/fstab || { BREAKVAR=1; break; }
						echo "# $(echo "$i" | awk -F ' ' '{ print $2 }')" >> /etc/fstab || { BREAKVAR=1; break; }
						echo "tmpfs $(echo "$i" | awk -F ' ' '{ print $2 }') tmpfs nodev,nosuid,size=$(echo "$i" \
						| awk -F ' ' '{ print $3 }')" >> /etc/fstab || { BREAKVAR=1; break; }
						echo >> /etc/fstab || { BREAKVAR=1; break; }
						;;
					symlink)
						if [[ $(echo "$i" | awk -F ' ' '{ print $2 }') == 'f=n' ]]; then
							echo "ln -s $(echo "$i" | awk -F ' ' '{ print $3 }') $(echo "$i" \
							| awk -F ' ' '{ print $4 }')" || { BREAKVAR=1; break; }
						elif [[ $(echo "$i" | awk -F ' ' '{ print $2 }') == 'f=y' ]]; then
							mkdir -p "$(echo "$i" | awk -F ' ' '{ print $3 }')" || { BREAKVAR=1; break; }
							echo "ln -s $(echo "$i" | awk -F ' ' '{ print $4 }') $(echo "$i" \
							| awk -F ' ' '{ print $5 }')" || { BREAKVAR=1; break; }
						fi
						;;
					bindmount)
						if [[ $(echo "$i" | awk -F ' ' '{ print $2 }') == 'f=n' ]]; then
							echo >> /etc/fstab || { BREAKVAR=1; break; }
							echo "# bind mount: $(echo "$i" | awk -F ' ' '{ print $3 }')" >> /etc/fstab || { BREAKVAR=1; break; }
							echo "$(echo "$i" | awk -F ' ' '{ print $3 }') $(echo "$i" \
							| awk -F ' ' '{ print $4 }') none rw,bind 0 0" >> /etc/fstab || { BREAKVAR=1; break; }
							echo >> /etc/fstab || { BREAKVAR=1; break; }
						elif [[ $(echo "$i" | awk -F ' ' '{ print $2 }') == 'f=y' ]]; then
							echo >> /etc/fstab || { BREAKVAR=1; break; }
							echo "# bind mount: $(echo "$i" | awk -F ' ' '{ print $4 }')" >> /etc/fstab || { BREAKVAR=1; break; }
							mkdir -p "$(echo "$i" | awk -F ' ' '{ print $3 }')" || { BREAKVAR=1; break; }
							echo "$(echo "$i" | awk -F ' ' '{ print $4 }') $(echo "$i" \
							| awk -F ' ' '{ print $5 }') none rw,bind 0 0" >> /etc/fstab || { BREAKVAR=1; break; }
							echo >> /etc/fstab || { BREAKVAR=1; break; }
						fi
						;;
					overlay)
						echo >> /etc/fstab || { BREAKVAR=1; break; }
						echo "# overlay: $(echo "$i" | awk -F ' ' '{ print $2 }')" >> /etc/fstab || { BREAKVAR=1; break; }
						OVLFSLD=$(echo "$i" | awk -F ' ' '{ print $2 }')
						OVLFSUD=$(echo "$i" | awk -F ' ' '{ print $3 }')
						OVLFSWD=$(echo "$i" | awk -F ' ' '{ print $4 }')
						echo "overlay /merged overlay noauto,lowerdir=${OVLFSLD},uperdir=${OVLFSUD},workdir=${OVLFSWD} 0 0" >> /etc/fstab \
						|| { BREAKVAR=1; break; }
						echo >> /etc/fstab || { BREAKVAR=1; break; }
						unset OVLFSLD
						unset OVLFSUD
						unset OVLFSWD
						;;
				esac
			done < <(cat "${CHROOT_DIR}/csystem_links" | sed '/^#/ d' | sed '/^\s*$/d') && pass || die "Failed"
			if [[ "${BREAKVAR}" == 0 ]]; then
				echo -e "[\e[32m*\e[0m] Creating \e[34msystem links\e[0m and requested \e[34mfstab\e[0m entries"
			else
				_rescue_shell "Failed configuring system links"
			fi
		fi
	else
		exit 1
	fi
}

_copy_function() {
	if [[ -n $(cat "${CHROOT_DIR}/$1" | sed '/^#/ d' | sed '/^\s*$/d') ]]; then
		_state_save "/etc/conf.d/$2"
		if cp "${CHROOT_DIR}/$1" "/etc/conf.d/$2"; then
			echo -e "[\e[32m*\e[0m] Configuring [\e[34m$3\e[0m]"
		else
			exit 1
		fi
	fi
}

_state_save() {
	if [[ ! -e "${CHROOT_DIR}/last_state" ]]; then
		mkdir -p "${CHROOT_DIR}/last_state"
	elif [[ -d "${CHROOT_DIR}/last_state" ]]; then
		if [[ -n "${CHROOT_DIR}" ]]; then
			rm -rf "${CHROOT_DIR}/last_state"
			mkdir -p "${CHROOT_DIR}/last_state"
		fi
	fi

	cp "$1" "${CHROOT_DIR}/last_state/"
}

_configure_system() {
	env-update > /dev/null 2>&1 && source /etc/profile
	PATH=${PATH}:${CHROOT_DIR}
	export PATH

	# TIMEZONE CONFIGURATION
	_configure_timezone

	# LOCALE CONFIGURATION
	_configure_locale

	if [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		# GENERATING FSTAB
		_configure_fstab
	elif [[ "${_ctflag_chroot}" == 'revert' ]]; then
		cp "${CHROOT_DIR}/last_state/fstab" "/etc/fstab"
	fi

	if [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		# CONFIGURE HOSTNAME
		_copy_function "chostname" "hostname" "hostname"

		# CONFIGURE /ETC/CONF.D/NET
		_copy_function "cnet" "net" "/etc/conf.d/net"

		# CONFIGURE /ETC/DEFAULT/GRUB
		_copy_function  "cgrub" "grub" "/etc/default/grub"
	
		# CONFIGURE SSHD
		_copy_function "csshd" "sshd" "/etc/ssh/sshd_config"

		### CUSTOM SCRIPTS ENTRIES WILL BE INCLUDED HERE

		### INSCRIPT ENTRIES WILL BE INCLUDED HERE

		# CONFIGURE SSH.PUB
		_state_save "/root/.ssh/authorized_keys"
		[[ -n $(cat "${CHROOT_DIR}/cssh.pub" | sed '/^#/ d' | sed '/^\s*$/d') ]] && mkdir -p /root/.ssh \
		&& if cat "${CHROOT_DIR}/cssh.pub" | sed '/^#/ d' | sed '/^\s*$/d' > /root/.ssh/authorized_keys; then
			echo -e "\e[33m----------------------------------------------------------------------------\e[0m"
			echo -e "[\e[32m*\e[0m] Adding ssh.pub key to [\e[34m/root/.ssh/authorized_keys\e[0m]"
			echo -e "\e[33m----------------------------------------------------------------------------\e[0m"
		else
			exit 1
		fi
	elif [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		cp "${CHROOT_DIR}/last_state/hostname" "/etc/conf.d/hostname"
		cp "${CHROOT_DIR}/last_state/net" "/etc/conf.d/net"
		cp "${CHROOT_DIR}/last_state/grub" "/etc/default/grub"
		cp "${CHROOT_DIR}/last_state/sshd" "/etc/ssh/sshd_config"
		cp "${CHROOT_DIR}/last_state/authorized_keys" "/root/.ssh/authorized_keys"
	fi
}

# RUNLEVEL UPDATE FUNCTION
_runlevel_configuration() {
	_update_runlevels() {
		{ while read -r i; do
			rc-update "$(echo "$i" | awk -F ' ' '{ print $2 }')" "$(echo $i | awk -F ' ' '{ print $1 }')" \
			"$(echo "$i" | awk -F ' ' '{ print $3 }')"
			sleep 0.5
		done < <(cat "$1" | sed '/^#/ d' | sed '/^\s*$/d'); } \
		&& { echo -e "[\e[32m*\e[0m] Updated successfully"; }
	}

	if [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		cat >"${CHROOT_DIR}/last_state/crunlevels" <<\EOF
		# Runlevel entries
		#
		# Add or remove entries from a specific runlevel
		# Please use this section with care! Misconfiguration here will make your systeom unbootable.
		#
		# Syntax: {daemon} {add/dell} {runlevel}
		# Example: distccd add default -> rc-update add distccd default
		#
		# This section together with custom scripts file, can make the system unbootable
EOF

		_rl_ar=()
		while read -r s; do
			_rl_ar+=($s)
		done < <(rc-update -v | awk -F '|'  '{ print $1}')

		for i in "${_rl_ar[@]}"; do
			if [[ -n "$(rc-update -v | grep udev | awk -F '|' '{print $2}'| sed "s/[^a-zA-Z]//g")" ]]; then
				_var1="$(rc-update -v | grep udev | awk -F '|' '{print $2}'| sed "s/[^a-zA-Z]//g" | sed '/^#/ d' | sed '/^\s*$/d' | head -n 1)"
				echo "$i add ${_var1}" >> "${CHROOT_DIR}/last_state/crunlevels"
				unset _var1
			fi
		done

		echo "# EOF" >> "${CHROOT_DIR}/last_state/crunlevels"
		unset _rl_ar
		_update_runlevels "${CHROOT_DIR}/crunlevels"
	elif [[ "${_ctflag_chroot}" == 'chroot' ]]; then
		_update_runlevels "${CHROOT_DIR}/last_state/crunlevels"
	fi
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
	[[ -z $(echo "$@") ]] && _print_info 3
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

