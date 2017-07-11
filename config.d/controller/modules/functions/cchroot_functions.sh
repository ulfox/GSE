#!/bin/bash

die() {
	echo "$@" 1>&2 ; exit 1
}
	
pass() {
	echo -e "[\e[34mDone\e[0m]"
}

_configure_timezone() {
	if [[ "${TIMEZONE}" != TMZ ]]; then
		echo "${TIMEZONE}" > /etc/timezone && echo -e "[\e[32m*\e[0m] Configuring \e[34mTimezone\e[0m"
	else
		echo "UTC" > /etc/timezone && echo -e "[\e[32m*\e[0m] \e[34mConfiguring Timezone\e[0m"
	fi

	if eval emerge --config sys-libs/timezone-data "${_chroot_silence}" | grep -q "invalid"; then
		if echo "UTC" >/etc/timezone; emerge --config sys-libs/timezone-data; then
			echo -e "[\e[32m*\e[0m] Resetting to UTC"
		else
			echo -e "[\e[31m*\e[0m] Resetting to UTC"
		fi
	fi
}

_configure_locale() {
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

	eselect locale set "${SETLOC}" && echo -e "[\e[32m*\e[0m] Setting locale to [\e[34men_US\e[0m]" \
	|| echo -e "[\e[31m*\e[0m] Failed setting locale to [\e[34men_US\e[0m]"
	unset SETLOC
}

_configure_fstab() {
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
		if cp "${CHROOT_DIR}/$1" /etc/conf.d/"$2"; then
			echo -e "[\e[32m*\e[0m] Configuring [\e[34m$3\e[0m]"
		else
			exit 1
		fi
	fi
}

configure_system_f() {
	env-update > /dev/null 2>&1 && source /etc/profile
	PATH=${PATH}:${CHROOT_DIR}
	export PATH

	# TIMEZONE CONFIGURATION
	_configure_timezone

	# LOCALE CONFIGURATION
	_configure_locale

	# GENERATING FSTAB
	_configure_fstab

	# CONFIGURE HOSTNAME
	_copy_function "chostname" "hostname" "hostname"

	# CONFIGURE /ETC/CONF.D/NET
	_copy_function "cnet" "net" "/etc/conf.d/net"

	# CONFIGURE /ETC/DEFAULT/GRUB
	_copy_function  "cgrub" "grub" "/etc/default/grub"

	### CUSTOM SCRIPTS ENTRIES WILL BE INCLUDED HERE

	### INSCRIPT ENTRIES WILL BE INCLUDED HERE

	# CONFIGURE SSHD
	_copy_function "csshd" "sshd" "/etc/ssh/sshd_config"

	# CONFIGURE SSH.PUB
	[[ -n $(cat "${CHROOT_DIR}/cssh.pub" | sed '/^#/ d' | sed '/^\s*$/d') ]] && mkdir -p /root/.ssh \
	&& if cat "${CHROOT_DIR}/cssh.pub" | sed '/^#/ d' | sed '/^\s*$/d' > /root/.ssh/authorized_keys; then
		echo -e "\e[33m----------------------------------------------------------------------------\e[0m"
		echo -e "[\e[32m*\e[0m] Adding ssh.pub key to [\e[34m/root/.ssh/authorized_keys\e[0m]"
		echo -e "\e[33m----------------------------------------------------------------------------\e[0m"
	else
		exit 1
	fi
}

# RUNLEVEL UPDATE FUNCTION
_runlevel_configuration() {
	env-update > /dev/null 2>&1 && source /etc/profile && export PS1="( 'Part G: Updating Runlevel Entries' ) $PS1"
	PATH=${PATH}:${CHROOT_DIR}
	export PATH
	{ while read -r i; do
		rc-update "$(echo "$i" | awk -F ' ' '{ print $2 }')" "$(echo $i | awk -F ' ' '{ print $1 }')" \
		"$(echo "$i" | awk -F ' ' '{ print $3 }')"
		sleep 0.5
	done < <(cat "${CHROOT_DIR}/crunlevels" | sed '/^#/ d' | sed '/^\s*$/d'); } \
	&& { echo -e "[\e[32m*\e[0m] Updated successfully"; }
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