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

    if [[ "${_flag_dhok}" != '0' ]]; then
        _flag_dhook=1
    fi

    # Install packages
    inst_multiple chroot chown chmod ls sed awk mount ls ln umount
    inst_multiple cp mv busybox rsync bash dmesg findmnt
    inst_multiple tar bzip2 clear scp lsblk tee sed awk
    inst_multiple fusermount strace rm vi grep ps uname

    # Network packages
    inst_multiple dhclient ping ping6 netstat netselect dhcpcd arping ifconfig

    # Fsck
    inst_multiple fsck fsck.ext2 fsck.ext4 fsck.ext3 fsck.ext4dev fsck.vfat e2fsck

    # Labels
    inst_multiple e2label mlabel swaplabel

    # Modules
    inst_multiple insmod rmmod modprobe lsmod

    # File systems packages
    inst_multiple mkfs.ext2 mkfs.ext3 mkfs.ext4 mkfs.btrfs mkfs.vfat

    # Ssh,gpg, and md5/sha sums
    inst_multiple ssh gpg md5sum sha224sum sha256sum sha384sum sha512sum

    # Install libs for the dns functions
    inst_simple "/lib64/libnss_dns.so.2"
    inst_simple "/lib64/libnss_files.so.2"
    inst_simple "/lib64/ld-linux-x86-64.so.2"
    inst_simple "/lib64/libresolv.so.2"
    inst_simple "/lib64/libc.so.6"
    inst_simple "/lib64/libmount.so.1"
    inst_simple "/lib64/libblkid.so.1"
    inst_simple "/lib64/libuuid.so.1"
    inst_simple "/lib64/ld-linux-x86-64.so.2"
    inst_simple "/lib64/libext2fs.so.2"
    inst_simple "/lib64/libcom_err.so.2"
    inst_simple "/lib64/libe2p.so.2"
    inst_simple "/lib64/libpthread.so.0"
    inst_simple "/lib64/libdl.so.2"
    inst_simple "/lib64/libz.so.1"
    inst_simple "/lib64/liblzo2.so.2"
    inst_simple "/usr/lib64/libfdisk.so.1.1.0"
    inst_simple "/lib64/libsmartcols.so.1"
    inst_simple "/lib64/libreadline.so.6"
    inst_simple "/lib64/libncurses.so.6"
    inst_simple "/usr/lib64/libncursesw.so"
    inst_simple "/usr/lib64/libncursesw.so"
    inst_simple "/usr/lib64/libmagic.so.1"
    inst_simple "/lib64/libncursesw.so.6"
    inst_simple "/lib64/libnss_files.so.2"
    inst_simple "/lib64/libattr.so.1"
    inst_simple "/lib64/libacl.so.1"
    inst_simple "/usr/lib64/libpopt.so.0"
    inst_simple "/lib64/libnss_compat.so.2"
    inst_simple "/lib64/libnsl.so.1"
    inst_simple "/lib64/libnss_nis.so.2"
    inst_simple "/lib64/libnss_dns.so.2"
    inst_simple "/lib64/libnss_files.so.2"
    inst_simple "/lib64/libresolv.so.2"
    inst_simple "/lib64/ld-linux-x86-64.so.2"
    
    # Create controller directory, rfs, bfs and workdir
    mkdir -m 0755 -p "${initdir}/config.d/fetchdir,confdir}"
    mkdir -m 0755 -p "${initdir}/config.d/confdir/{local,keys,jobs}"
    mkdir -m 0755 -p "${initdir}/etc/gse"
    mkdir -m 0755 -p "${initdir}/usr/local/controller"
    mkdir -m 700 -p "${initdir}/root/.ssh"
    mkdir -m 0755 -p "${initdir}/mnt/{rfs,bfs}"
    mkdir -m 0755 -p "${initdir}/mnt/{etc_tmpfs,tmp_tmpfs,var_tmp_tmpfs,workdir}"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/{local,nfs,log,var,etc}"
    mkdir -m 0755 -p "${initdir}/user-data/persistent/local/{root,home,data,mnt,media}"

    # Install scripts for the controller process
    inst_script "$moddir/functions/cchroot.sh" "/usr/local/controller/cchroot.sh"
    inst_script "$moddir/functions/net_script.sh" "/bin/net_script.sh"
    inst_script "$moddir/functions/cbootflags.sh" "/usr/local/controller/cbootflags.sh"
    inst_script "$moddir/functions/cfunctions.sh" "/usr/local/controller/cfunctions.sh"
    inst_script "$moddir/functions/chealth.sh" "/usr/local/controller/chealth.sh"
    inst_script "$moddir/functions/cnetwork.sh" "/usr/local/controller/cnetwork.sh"
    inst_script "$moddir/functions/ccrevert_chroot.sh" "/usr/local/controller/ccrevert_chroot.sh"
    
    # Install configuration files
    inst_simple "$moddir/sources/sources.conf" "config.d/confdir/sources/sources.conf"
    inst_simple "$moddir/sources/servers" "config.d/confdir/sources/servers"
    inst_simple "$moddir/files/cssh_config" "/etc/ssh/ssh_config"
    inst_simple "$moddir/files/cknown_hosts" "/root/.ssh/known_hosts"
    inst_simple "$moddir/files/cssh_priv" "/root/.ssh/ida_rsa"
    inst_simple "$moddir/files/cgentoo.conf" "/etc/gse/gentoo.conf"
    inst_simple "$moddir/files/csources.conf" "/etc/gse/sources.conf"
    inst_simple "$moddir/files/cservers.conf" "/etc/gse/servers.conf"
    inst_simple "$moddir/files/cfstab" "/etc/fstab"
    inst_simple "$moddir/files/cnet" "/config.d/confdir/net"
    inst_simple "$moddir/files/cconsolefont" "/config.d/confdir/consolefont"
    inst_simple "$moddir/files/crunlevels" "/config.d/confdir/runlevels"
    inst_simple "$moddir/files/cdevname.info" "/config.d/confdir/devname.info"
    inst_simple "$moddir/files/conf.d/cfstab.info" "/config.d/confdir/fstab.info"
    inst_simple "$moddir/files/ccustom_scripts" "/config.d/confdir/ccustom_scripts"
    inst_simple "$moddir/files/cgrub" "/config.d/confdir/grub"
    inst_simple "$moddir/files/ccoptions" "/config.d/confdir/coptions"
    inst_simple "$moddir/files/chostname" "/config.d/confdir/hostname"
    inst_simple "$moddir/files/chosts" "/config.d/confdir/hosts"
    inst_simple "$moddir/files/clocale.gen" "/config.d/confdir/locale.gen"
    inst_simple "$moddir/files/cssh.pub" "/config.d/confdir/ssh.pub"
    inst_simple "$moddir/files/csshd_config" "/config.d/confdir/sshd_config"
    inst_simple "$moddir/files/csystem_links" "/config.d/confdir/system_links"

    # Install the hookpoints for the controller process {here the process is defined}
    inst_hook pre-mount 01 "$moddir/cinit_pre-mount.sh"
    inst_hook mount 01 "$moddir/cinit_mount.sh"
    inst_hook clean 01 "$moddir/cinit_clean.sh"
    
    mkdir -m 0755 -p "${initdir}/usr/local/unet"
    
    if [[ "${_flag_dracut_net}" == 0 ]]; then
        inst_hook pre-mount 02 "${_flag_drnet}"
        inst_script "${_flag_drnet}" "${initdir}/usr/local/unet"
        echo "net:0" > "${initdir}/usr/local/unet/udent_flag"
    else
        echo "net:1" > "${initdir}/usr/local/unet/udent_flag"
    fi

    mkdir -m 0755 -p "${initdir}/usr/local/uscripts"

    if [[ "${_flag_dhook}" == 0 ]]; then
        for i in "${_hook_final[@]}"; do
            inst_script "${_dhook_ar[$i]}" "${initdir}/usr/local/uscripts/"
            _tmp_hp="$(echo ${_hook_final[$i]} | awk -F ',' '{print $1}')"
            _tmp_pr="$(echo ${_hook_final[$i]} | awk -F ',' '{print $2}')"
            _tmp_scname="$(echo ${_hook_final[$i]} | awk -F ',' '{print $3}')"
            
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

    mkdir -m 0755 -p "${initdir}/usr/local/mods"
    mkdir -m 0775 -p "${initdir}/usr/local/mods/{minsmod,mmodprob,mblacklist}"

    if [[ "${_flag_mods}" == 0 ]]; then
        echo "umods:0" > "${initdir}/usr/local/mods/umods"
        
        for i in "modprobe" "insmod" "blacklist"; do
            case "$i" in
               modprobe)
                    echo "modprobe:0" > "${initdir}/local/mods/modprobe"
                    echo "${_modprobe_ar[@]}" >> "${initdir}/local/mods/modprobe"
                    for i in "${_modprobe_ar[@]}"; do
                        inst_simple "$i" "${initdir}/local/mods/mmodprob/$i"
                    done
                    ;;

                insmod)
                    echo "insmod:0" > "${initdir}/usr/local/mods/insmod"
                    echo "${_insmod_ar[@]}" >> "${initdir}/local/mods/insmod"
                    for i in "${_insmod_ar[@]}"; do
                        inst_simple "$i" "${initdir}/local/mods/minsmod/$i"
                    done
                    ;;

                blacklist)
                    echo "blacklist:0" > "${initdir}/usr/local/mods/blacklist"
                    echo "${_blacklist_ar[@]}" >> "${initdir}/local/mods/blacklist"
                    for i in "${_blacklist_ar[@]}"; do
                        inst_simple "$i" "${initdir}/local/mods/mblacklist/$i"
                    done
                    ;;
                esac
            fi
        done
    else
        echo "umods:1" > "${initdir}/usr/local/mods/umods"
    fi
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