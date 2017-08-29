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

    # Install packages
    inst_multiple chroot chown chmod ls sed awk mount ls ln umount tail
    inst_multiple cp mv busybox rsync dmesg findmnt dirname head
    inst_multiple tar bash bzip2 clear scp lsblk tee sed awk basename sync
    inst_multiple fusermount strace wipefs rm grep ps uname du find uname fdisk

    # test
    inst_multiple vim nano vi sensors ssh sshd
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
    inst_script "$moddir/functions/cchroot_functions.sh" "/usr/local/controller/cchroot_functions.sh"
    inst_script "$moddir/functions/check_con.sh" "/usr/local/controller/check_con.sh"
    inst_script "$moddir/functions/cnetwork.sh" "/usr/local/controller/cnetwork.sh"
    inst_script "$moddir/functions/ct_config.sh" "/usr/local/controller/ct_config.sh"
    inst_script "$moddir/functions/ct_devices.sh" "/usr/local/controller/ct_devices.sh"
    inst_script "$moddir/functions/ct_fetch.sh" "/usr/local/controller/ct_fetch.sh"
    inst_script "$moddir/functions/ct_netf.sh" "/usr/local/controller/ct_netf.sh"
    inst_script "$moddir/functions/ct_newsys.sh" "/usr/local/controller/ct_newsys.sh"
    inst_script "$moddir/functions/ct_prelim.sh" "/usr/local/controller/ct_prelim.sh"
    inst_script "$moddir/functions/net_script.sh" "/usr/local/controller/net_script.sh"

    inst_script "$moddir/functions/cfunctions.sh" "/usr/local/controller/cfunctions.sh"
    inst_script "$moddir/functions/chealth.sh" "/usr/local/controller/chealth.sh"

    
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
    inst_simple "$moddir/sources/sources.conf" "/config.d/sources.conf"

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
    if [[ -e "${moddir}/unet/unet.conf" ]]; then
        _unetscript="$(cat ${moddir}/unet/unet.conf)"
        if [[ -e "${moddir}/unet/${_unetscript}" ]]; then
            inst_hook pre-mount 08 "${moddir}/unet/${_unetscript}"
            inst_script "${moddir}/unet/${_unetscript}" "/usr/local/unet/unet.sh"
        fi
    fi

    # CUSTOM HOOK SCRIPTS
    mkdir -m 0755 -p "${initdir}/usr/local/uscripts"

    if [[ -e "${moddir}/uscripts/insthook" ]]; then
        while read s; do
                
                _tmp_hp="$(echo "$s" | awk -F ' ' '{print $1}')"
                _tmp_pr="$(echo "$s" | awk -F ' ' '{print $2}')"
                _tmp_scname="$(echo "$s" | awk -F ' ' '{print $3}')"
                
                if [[ -e "${moddir}/uscripts/${_tmp_scname}" ]]; then
                    eval inst_hook "${_tmp_hp}" "${_tmp_pr}" "${moddir}/uscripts/${_tmp_scname}"
                fi
        done < <(cat "${moddir}/uscripts/insthook")
    fi

    unset _crpt_cnt
    unset _tmp_hp
    unset _tmp_p
    unset _tmp_scname

    # KERNEL MODULES
    mkdir -m 0775 -p "${initdir}/etc/modprobe.d"

    if [[ -e "${moddir}/umod/umod.conf" ]]; then
        _umodname="$(cat "${moddir}/umod/umod.conf")"
        if [[ -e "${moddir}/umod/${_umodname}" ]]; then
            inst_simple "${moddir}/umod/${_umodname}" "/etc/modprobe.d/umod.conf"
        fi
    fi

    # Install the hookpoints for the controller process {here the process is defined}
    inst_hook pre-mount 02 "$moddir/init_script.sh"
    inst_hook pre-mount 03 "$moddir/cinit_pre-mount.sh"
    #inst_hook mount 08 "$moddir/cinit_mount.sh"
    #inst_hook clean 08 "$moddir/cinit_clean.sh"

}

# called by dracut
installkernel() {
    # Include kernel modules
    # Please note that these modules are for testing
    # Controller does not require most of them, as it does not require
    # many of the above installed packages.
    #
    # However the development is mostly done inside the initramfs, so that's why these packages and tools
    # If you wish to do your own testing, please remove the hardware specific modules like radeon and intel for example
    # and add your own. You can add your own packages above, but dont remove essential packages that are used by the scripts
    #
    #
    
    hostonly='' instmods sr_mod
    hostonly='' instmods cdrom
    hostonly='' instmods sr_mod
    hostonly='' instmods sd_mod
    hostonly='' instmods radeon
    hostonly='' instmods ttm
    hostonly='' instmods drm_kms_helper
    hostonly='' instmods iTCO_wdt
    hostonly='' instmods iTCO_vendor_support
    hostonly='' instmods ppdev
    hostonly='' instmods snd_hda_codec_realtek
    hostonly='' instmods snd_hda_codec_generic
    hostonly='' instmods snd_hda_codec_hdmi
    hostonly='' instmods coretemp
    hostonly='' instmods drm
    hostonly='' instmods radeon
    hostonly='' instmods kvm_intel
    hostonly='' instmods snd_hda_intel
    hostonly='' instmods snd_hda_codec
    hostonly='' instmods ata_generic
    hostonly='' instmods pata_acpi
    hostonly='' instmods kvm_intel
    hostonly='' instmods snd_hda_core
    hostonly='' instmods ahci
    hostonly='' instmods snd_hwdep
    hostonly='' instmods syscopyarea
    hostonly='' instmods i2c_i801
    hostonly='' instmods ata_piix
    hostonly='' instmods r8169
    hostonly='' instmods libahci
    hostonly='' instmods pata_jmicron
    hostonly='' instmods lpc_ich
    hostonly='' instmods irqbypass
    hostonly='' instmods kvm
    hostonly='' instmods mfd_core
    hostonly='' instmods mii
    hostonly='' instmods sysfillrect
    hostonly='' instmods snd_pcm
    hostonly='' instmods crc32c_intel
    hostonly='' instmods snd_timer
    hostonly='' instmods pcspkr
    hostonly='' instmods serio_raw
    hostonly='' instmods snd
    hostonly='' instmods sysimgblt
    hostonly='' instmods fb_sys_fops
    hostonly='' instmods i2c_algo_bit
    hostonly='' instmods i2c_core
    hostonly='' instmods parport_pc
    hostonly='' instmods soundcore
    hostonly='' instmods parport
    hostonly='' instmods ppdev
    hostonly='' instmods dm_multipath
    hostonly='' instmods sunrpc
    hostonly='' instmods dm_mirror
    hostonly='' instmods dm_region_hash
    hostonly='' instmods dm_log
    hostonly='' instmods dm_mod
    hostonly='' instmods dax
    
    hostonly='' instmods jbd2
    hostonly='' instmods fscrypto
    hostonly='' instmods mbcache
    hostonly='' instmods ext4
    hostonly='' instmods btrfs
    hostonly='' instmods vfat
    hostonly='' instmods fat
    hostonly='' instmods xor

    #instmods "=drivers"
    #instmods "=arch"
    #instmods "=crypto"
    #instmods "=fs"
    #instmods "=lib"
    #instmods "=mm"
    #instmods "=net"
    #instmods "=sound"
}