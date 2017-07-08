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
    inst_multiple chroot chown chmod ls sed awk mount ls ln umount
    inst_multiple cp mv busybox rsync ssh gpg bash rmmod dmesg modprobe findmnt
    inst_multiple tar bzip2 ping clear mkfs.ext2 mkfs.ext3 mkfs.ext4 mkfs.btrfs mkfs.vfat
    inst_multiple e2label mlabel swaplabel scp md5sum sha512sum lsblk tee sed awk arping
    inst_multiple dhclient ifconfig scp lsmod

    # Install libs for the dns functions
    inst_simple "/lib64/libnss_dns.so.2"
    inst_simple "/lib64/libnss_files.so.2"
    inst_simple "/lib64/ld-linux-x86-64.so.2"
    inst_simple "/lib64/libresolv.so.2"
    inst_simple "/lib64/libc.so.6"

    # Create controller directory, rfs, bfs and workdir
    mkdir -m 0755 -p ${initdir}/config.d/fetchdir,confdir}
    mkdir -m 0755 -p ${initdir}/config.d/confdir/{local,keys,jobs}
    mkdir -m 0755 -p ${initdir}/etc/gse
    mkdir -m 0755 -p ${initdir}/usr/local/controller
    mkdir -m 700 -p ${initdir}/root/.ssh
    mkdir -m 0755 -p ${initdir}/mnt/{rfs,bfs}
    mkdir -m 0755 -p ${initdir}/mnt/{etc_tmpfs,tmp_tmpfs,var_tmp_tmpfs,workdir}
    mkdir -m 0755 -p ${initdir}/user-data/persistent/{local,nfs,log,var,etc}
    mkdir -m 0755 -p ${initdir}/user-data/persistent/local/{root,home,data,mnt,media}

    # Install scripts for the controller process
    inst_script "$moddir/functions/cchroot.sh" "/usr/local/controller/cchroot.sh"
    inst_script "$moddir/functions/net_script.sh" "/bin/net_script.sh"
    inst_script "$moddir/functions/cbootflags.sh" "/usr/local/controller/cbootflags.sh"
    inst_script "$moddir/functions/cfetch.sh" "/usr/local/controller/cfetch.sh"
    inst_script "$moddir/functions/cfunctions.sh" "/usr/local/controller/cfunctions.sh"
    inst_script "$moddir/functions/chealth.sh" "/usr/local/controller/chealth.sh"
    inst_script "$moddir/functions/cnetwork.sh" "/usr/local/controller/cnetwork.sh"
    inst_script "$moddir/functions/cverify.sh" "/usr/local/controller/cverify.sh"
    
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