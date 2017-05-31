#!/bin/bash

mkdir -p "$NEWROOT/.etc"
mount -t tmpfs tmpfs "$NEWROOT/.etc"
rsync -aAXPhrv "$NEWROOT/etc/" "$NEWROOT/.etc" >/dev/null 2>&1
mount --move "$NEWROOT/.etc" "$NEWROOT/etc"

mkdir -p "$NEWROOT/.var"
mkdir -p "$NEWROOT/.tmp"
mount -t tmpfs -o size=2G tmpfs "$NEWROOT/.var"
mount -t tmpfs -o size=5G tmpfs "$NEWROOT/.tmp"
rsync -aAXPhrv "$NEWROOT/var/" "$NEWROOT/.var" >/dev/null 2>&1
rsync -aAXPhrv "$NEWROOT/tmp/" "$NEWROOT/.tmp" >/dev/null 2>&1
mount --move "$NEWROOT/.var" "$NEWROOT/var"
mount --move "$NEWROOT/.tmp" "$NEWROOT/tmp"




