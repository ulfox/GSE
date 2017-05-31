#!/bin/bash

# called by dracut
check() {
    if [[ -e $moddir/rsync.sh ]]; then
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
	dracut_install -o rsync nano ifconfig ping clear
	inst_hook cleanup 01 "$moddir/etc_tmpfs.sh"
}
