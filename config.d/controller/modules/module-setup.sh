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
# Hooks the script to clean up phase
    inst_multiple chroot chown chmod ls sed awk mount ls ln umount \
    cp mv busybox rsync ssh gpg bash rmmod dmesg modprobe findmnt \
    tar bzip2 ping clear mkfs.ext2 mkfs.ext3 mkfs.ext4 mkfs.btrfs mkfs.vfat \
    e2label mlabel swaplabel scp md5sum sha512sum lsblk tee sed awk arping \
    dhclient

    inst_simple "/lib64/libnss_dns.so.2"
    inst_simple "/lib64/libnss_files.so.2"
    inst_simple "/lib64/ld-linux-x86-64.so.2"
    inst_simple "/lib64/libresolv.so.2"
    inst_simple "/lib64/libc.so.6"

    mkdir -m 0755 -p ${initdir}/config.d/fetchdir,confdir}
    mkdir -m 0755 -p ${initdir}/config.d/confdir/{local,keys,jobs}
    mkdir -m 0755 -p ${initdir}/etc/gse
    mkdir -m 0755 -p ${initdir}/usr/local/controller
    mkdir -m 700 -p ${initdir}/root/.ssh
    mkdir -m 0755 -p ${initdir}/mnt/{rfs,bfs}
    mkdir -m 0755 -p ${initdir}/mnt/{etc_tmpfs,tmp_tmpfs,var_tmp_tmpfs,workdir}
    mkdir -m 0755 -p ${initdir}/user-data/persistent/{local,nfs,log,var,etc}
    mkdir -m 0755 -p ${initdir}/user-data/persistent/local/{root,home,data,mnt,media}

    inst_script "$moddir/cchroot.sh" "/usr/local/controller/cchroot.sh"
    inst_script "$moddir/net_script.sh" "/bin/net_script.sh"
    inst_script "$moddir/cbootflags.sh" "/usr/local/controller/cbootflags.sh"
    inst_script "$moddir/cfetch.sh" "/usr/local/controller/cfetch.sh"
    inst_script "$moddir/cfunctions.sh" "/usr/local/controller/cfunctions.sh"
    inst_script "$moddir/chealth.sh" "/usr/local/controller/chealth.sh"
    inst_script "$moddir/cnetwork.sh" "/usr/local/controller/cnetwork.sh"
    inst_script "$moddir/cverify.sh" "/usr/local/controller/cverify.sh"
    inst_simple "${CHDIR}/controller/cssh_config" "/etc/ssh/ssh_config"
    inst_simple "${CHDIR}/controller/cknown_hosts" "/root/.ssh/known_hosts"
    inst_simple "${CHDIR}/controller/cssh_priv" "/root/.ssh/ida_rsa"
    inst_simple "${CHDIR}/controller/cgentoo.conf" "/etc/gse/gentoo.conf"
    inst_simple "${CHDIR}/controller/csources.conf" "/etc/gse/sources.conf"
    inst_simple "${CHDIR}/controller/cservers.conf" "/etc/gse/servers.conf"
    inst_simple "${CHDIR}/controller/cfstab" "/etc/fstab"
    inst_simple "${CHDIR}/controller/cnet" "/config.d/confdir/net"
    inst_simple "${CHDIR}/controller/cconsolefont" "/config.d/confdir/consolefont"
    inst_simple "${CHDIR}/controller/crunlevels" "/config.d/confdir/runlevels"
    inst_simple "${CHDIR}/controller/cdevname.info" "/config.d/confdir/devname.info"
    inst_simple "${CHDIR}/controller/conf.d/cfstab.info" "/config.d/confdir/fstab.info"
    inst_simple "${CHDIR}/controller/cgrub" "/config.d/confdir/grub"
    inst_simple "${CHDIR}/controller/ccoptions" "/config.d/confdir/coptions"
    inst_simple "${CHDIR}/controller/chostname" "/config.d/confdir/hostname"
    inst_simple "${CHDIR}/controller/chosts" "/config.d/confdir/hosts"
    inst_simple "${CHDIR}/controller/clocale.gen" "/config.d/confdir/locale.gen"
    inst_simple "${CHDIR}/controller/cssh.pub" "/config.d/confdir/ssh.pub"
    inst_simple "${CHDIR}/controller/csshd_config" "/config.d/confdir/sshd_config"
    inst_simple "${CHDIR}/controller/csystem_links" "/config.d/confdir/system_links"

    inst_hook pre-mount 01 "$moddir/cinit_pre-mount.sh"
    #inst_hook mount 01 "$moddir/cinit_mount.sh"
    #inst_hook clean 01 "$moddir/cinit_clean.sh"

}
