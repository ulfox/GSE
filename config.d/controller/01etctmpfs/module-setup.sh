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
# Hooks the script to clean up phase
	inst_hook cleanup 01 "$moddir/etc_tmpfs.sh"
}
