#!/bin/bash

# called by dracut
check() {
    if [[ -e $moddir/cinit_pre-mount.sh ]]; then
    {
        return 0
    }
    else
    {
        return 1
    }
    fi
}

# called by dracut
install() {
    if [[ "${_flag_dracut_net}" != '0' ]]; then
        _flag_dracut_net=1
    fi

    if [[ "${_flag_dhook}" != '0' ]]; then
        _flag_dhook=1
    fi

    # Install packages
    inst_multiple chroot chown chmod ls sed awk mount ls ln umount tail
    inst_multiple cp mv busybox rsync bash dmesg findmnt dirname head
    inst_multiple tar bzip2 clear scp lsblk tee sed awk basename sync
    inst_multiple fusermount strace wipefs rm grep ps uname du find uname fdisk

    # test
    inst_multiple vim nano vi sensors ssh sshd
    inst_multiple usermod useradd userdel users groupadd groupdel groupmems groupmod groups
    inst_simple "/etc/ssh/ssh_config" "/etc/ssh/ssh_config"
    inst_simple "/etc/ssh/sshd_config" "/etc/ssh/sshd_config"

    # Network packages
    _ct_netmod() {
        inst_multiple dhclient ping ping6 netstat netselect dhcpcd arping ifconfig ip

        # Install libs for the dns functions
        inst_simple "/lib64/libnss_dns.so.2" "/lib64/libnss_dns.so.2"
        inst_simple "/lib64/libnss_files.so.2" "/lib64/libnss_files.so.2"
        inst_simple "/lib64/ld-linux-x86-64.so.2" "/lib64/ld-linux-x86-64.so.2"
        inst_simple "/lib64/libresolv.so.2" "/lib64/libresolv.so.2"
        inst_simple "/lib64/libc.so.6" "/lib64/libc.so.6"
        inst_simple "/lib64/libmount.so.1" "/lib64/libmount.so.1"
        inst_simple "/lib64/libblkid.so.1" "/lib64/libblkid.so.1"
        inst_simple "/lib64/libuuid.so.1" "/lib64/libuuid.so.1"
        inst_simple "/lib64/ld-linux-x86-64.so.2" "/lib64/ld-linux-x86-64.so.2"
        inst_simple "/lib64/libext2fs.so.2" "/lib64/libext2fs.so.2"
        inst_simple "/lib64/libcom_err.so.2" "/lib64/libcom_err.so.2"
        inst_simple "/lib64/libe2p.so.2" "/lib64/libe2p.so.2"
        inst_simple "/lib64/libpthread.so.0" "/lib64/libpthread.so.0"
        inst_simple "/lib64/libdl.so.2" "/lib64/libdl.so.2"
        inst_simple "/lib64/libz.so.1" "/lib64/libz.so.1"
        inst_simple "/lib64/liblzo2.so.2" "/lib64/liblzo2.so.2"
        inst_simple "/usr/lib64/libfdisk.so.1.1.0" "/usr/lib64/libfdisk.so.1.1.0"
        inst_simple "/lib64/libsmartcols.so.1" "/lib64/libsmartcols.so.1"
        inst_simple "/lib64/libreadline.so.6" "/lib64/libreadline.so.6"
        inst_simple "/lib64/libncurses.so.6" "/lib64/libncurses.so.6"
        inst_simple "/usr/lib64/libncursesw.so" "/usr/lib64/libncursesw.so"
        inst_simple "/usr/lib64/libncursesw.so" "/usr/lib64/libncursesw.so"
        inst_simple "/usr/lib64/libmagic.so.1" "/usr/lib64/libmagic.so.1"
        inst_simple "/lib64/libncursesw.so.6" "/lib64/libncursesw.so.6"
        inst_simple "/lib64/libnss_files.so.2" "/lib64/libnss_files.so.2"
        inst_simple "/lib64/libattr.so.1" "/lib64/libattr.so.1"
        inst_simple "/lib64/libacl.so.1" "/lib64/libacl.so.1"
        inst_simple "/usr/lib64/libpopt.so.0" "/usr/lib64/libpopt.so.0"
        inst_simple "/lib64/libnss_compat.so.2" "/lib64/libnss_compat.so.2"
        inst_simple "/lib64/libnsl.so.1" "/lib64/libnsl.so.1"
        inst_simple "/lib64/libnss_nis.so.2" "/lib64/libnss_nis.so.2"
        inst_simple "/lib64/libnss_dns.so.2" "/lib64/libnss_dns.so.2"
        inst_simple "/lib64/libnss_files.so.2" "/lib64/libnss_files.so.2"
        inst_simple "/lib64/libresolv.so.2" "/lib64/libresolv.so.2"
        inst_simple "/lib64/ld-linux-x86-64.so.2" "/lib64/ld-linux-x86-64.so.2"

    }

    # Fsck
    inst_multiple fsck fsck.ext2 fsck.ext4 fsck.ext3 fsck.ext4dev fsck.vfat e2fsck

    # Labels
    inst_multiple e2label mlabel swaplabel

    # Modules
    inst_multiple insmod rmmod modprobe lsmod

    # File systems packages
    inst_multiple mkfs.ext2 mkfs.ext3 mkfs.ext4 mkfs.btrfs mkfs.vfat
    
    # Create controller directory, rfs, bfs and workdir
    mkdir -m 0755 -p "${initdir}/config.d/confdir"
    mkdir -m 0755 -p "${initdir}/usr/local/controller"
    mkdir -m 700 -p "${initdir}/root/.ssh"
    mkdir -m 0755 -p "${initdir}/mnt/rfs"
    mkdir -m 0755 -p "${initdir}/mnt/bfs"
    mkdir -m 0755 -p "${initdir}/mnt/etc_tmpfs"
    mkdir -m 0755 -p "${initdir}/mnt/tmp_tmpfs"
    mkdir -m 0755 -p "${initdir}/mnt/var_tmp_tmpfs"
    mkdir -m 0755 -p "${initdir}/mnt/workdir"
    mkdir -m 0755 -p "${initdir}/user-data/persistent"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/nfs"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/log"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/var"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/etc"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/root"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/home"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/data"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/mnt"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/media"

    # Install scripts for the controller process
    inst_script "$moddir/functions/cchroot.sh" "/usr/local/controller/cchroot.sh"
    inst_script "$moddir/functions/net_script.sh" "/usr/local/controller/net_script.sh"
    inst_script "$moddir/functions/cbootflags.sh" "/usr/local/controller/cbootflags.sh"
    inst_script "$moddir/functions/cfunctions.sh" "/usr/local/controller/cfunctions.sh"
    inst_script "$moddir/functions/chealth.sh" "/usr/local/controller/chealth.sh"
    inst_script "$moddir/functions/cnetwork.sh" "/usr/local/controller/cnetwork.sh"
    inst_script "$moddir/functions/ccrevert_chroot.sh" "/usr/local/controller/ccrevert_chroot.sh"
    
    # Install configuration files for controller

    # SSH Configuration
    # To enable ssh, please include your priv key at "${CCONFD}/controller/modules/files/ssh/cssh_priv"
    mkdir -m 0755 -p "${initdir}/usr/local/controller/ssh"
    # INSTALL SSH
    inst_simple ssh 
    inst_simple sshd
    # CONFIGURATION FILE
    inst_simple "$moddir/files/controller_ssh/cssh_config" "/etc/ssh/ssh_config"
    inst_simple "$moddir/files/controller_ssh/cssh_config" "/usr/local/controller/ssh/ssh_config.backup"

    # KNOWN HOSTS
    inst_simple "$moddir/files/controller_ssh/cknown_hosts" "/root/.ssh/known_hosts"
    inst_simple "$moddir/files/controller_ssh/cknown_hosts" "/usr/local/controller/ssh/known_hosts.backup"

    # PRIVATE KEY (CLIENTS -> SERVER)
    inst_simple "$moddir/files/controller_ssh/cssh_priv" "/root/.ssh/ida_rsa"
    inst_simple "$moddir/files/controller_ssh/cssh_priv" "/usr/local/controller/ssh/ida_rsa.backup"
    
    # GPG
    mkdir -m 0755 -p "${initdir}/usr/local/controller/gpg"
    inst_simple gpg
    inst_simple "$moddir/files/controller_gpg/gpg_pub" "/usr/local/controller/gpg/gpg_pub"
    
    # SUMS
    inst_multiple md5sum sha224sum sha256sum sha384sum sha512sum 

    # FSTAB FILE FOR MOUNTING DRIVES ON INITRAMFS PHASE
    if [[ -e "$moddir/files/cfstab" ]]; then
        inst_simple "$moddir/files/cfstab" "/etc/fstab"
    fi

    # Install configuration files for the system
    inst_simple "$moddir/files/cdevname.info" "/config.d/cdevname.info"

    inst_simple "$moddir/files/system_configs/cnet" "/config.d/confdir/net"
    inst_simple "$moddir/files/system_configs/cconsolefont" "/config.d/confdir/consolefont"
    inst_simple "$moddir/files/system_configs/crunlevels" "/config.d/confdir/runlevels"
    inst_simple "$moddir/files/system_configs/cfstab.info" "/config.d/confdir/fstab.info"
    inst_simple "$moddir/files/system_configs/cgrub" "/config.d/confdir/grub"
    inst_simple "$moddir/files/system_configs/chostname" "/config.d/confdir/hostname"
    inst_simple "$moddir/files/system_configs/chosts" "/config.d/confdir/hosts"
    inst_simple "$moddir/files/system_configs/clocale.gen" "/config.d/confdir/locale.gen"
    inst_simple "$moddir/files/system_configs/cssh.pub" "/config.d/confdir/ssh.pub"
    inst_simple "$moddir/files/system_configs/csshd" "/config.d/confdir/sshd_config"
    inst_simple "$moddir/files/system_configs/csystem_links" "/config.d/confdir/system_links"
    
    # NETWORK
    mkdir -m 0755 -p "${initdir}/usr/local/unet"
    _ct_netmod

    # CUSTOM NETSCRIPT
    if [[ "${_flag_dracut_net}" == 0 ]]; then
        inst_hook pre-mount 08 "${_flag_drnet}"
        inst_script "${_flag_drnet}" "${initdir}/usr/local/unet/unet.sh"
        echo "net:0" > "${initdir}/usr/local/unet/udent_flag"
    else
        echo "net:1" > "${initdir}/usr/local/unet/udent_flag"
    fi

    # CUSTOM HOOK SCRIPTS
    mkdir -m 0755 -p "${initdir}/usr/local/uscripts"

    if [[ "${_flag_dhook}" == 0 ]]; then
        for i in "${_hook_final[@]}"; do
            inst_script "${_dhook_ar[$i]}" "${initdir}/usr/local/uscripts/"
            _tmp_hp="$(echo "${_hook_final[$i]}" | awk -F ',' '{print $1}')"
            _tmp_pr="$(echo "${_hook_final[$i]}" | awk -F ',' '{print $2}')"
            _tmp_scname="$(echo "${_hook_final[$i]}" | awk -F ',' '{print $3}')"
            
            inst_hook "${_tmp_hp}" "${_tmp_pr}" "${_tmp_scname}"
        done

        echo "uscripts:0" > "${initdir}/usr/local/uscripts/uscripts_flag"
        echo "${_dhook_ar[@]}" >> "${initdir}/usr/local/uscripts/uscripts_flag"
    else
        echo "uscripts:1" > "${initdir}/usr/local/uscripts/uscripts_flag"
    fi

    unset _tmp_hp
    unset _tmp_pr
    unset _tmp_scname

    # KERNEL MODULES
    mkdir -m 0755 -p "${initdir}/usr/local/mods"
    mkdir -m 0775 -p "${initdir}/usr/local/mods/{minsmod,mmodprob,mblacklist}"

    if [[ "${_flag_mods}" == 0 ]]; then
        echo "umods:0" > "${initdir}/usr/local/mods/umods"
        
        for i in "modprobe" "insmod" "blacklist"; do
            case "$i" in
               modprobe)
                    echo "modprobe:0" > "${initdir}/local/mods/modprobe"
                    echo "${_modprobe_ar[@]}" >> "${initdir}/local/mods/modprobe"
                    for j in "${_modprobe_ar[@]}"; do
                        inst_simple "$j" "${initdir}/local/mods/mmodprob/$j"
                    done
                    ;;

                insmod)
                    echo "insmod:0" > "${initdir}/usr/local/mods/insmod"
                    echo "${_insmod_ar[@]}" >> "${initdir}/local/mods/insmod"
                    for j in "${_insmod_ar[@]}"; do
                        inst_simple "$j" "${initdir}/local/mods/minsmod/$j"
                    done
                    ;;

                blacklist)
                    echo "blacklist:0" > "${initdir}/usr/local/mods/blacklist"
                    echo "${_blacklist_ar[@]}" >> "${initdir}/local/mods/blacklist"
                    for j in "${_blacklist_ar[@]}"; do
                        inst_simple "$j" "${initdir}/local/mods/mblacklist/$j"
                    done
                    ;;
                esac
        done
    else
        echo "umods:1" > "${initdir}/usr/local/mods/umods"
    fi

    # Install the hookpoints for the controller process {here the process is defined}
    inst_hook pre-mount 08 "$moddir/init_script.sh"
    #inst_hook pre-mount 08 "$moddir/cinit_pre-mount.sh"
    #inst_hook mount 08 "$moddir/cinit_mount.sh"
    #inst_hook clean 08 "$moddir/cinit_clean.sh"

}

# called by dracut
installkernel() {
    # Include kernel modules
    instmods "=drivers"
    instmods "=arch"
    instmods "=crypto"
    instmods "=fs"
    instmods "=lib"
    instmods "=mm"
    instmods "=net"
    instmods "=sound"
}