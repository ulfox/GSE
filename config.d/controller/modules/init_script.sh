#!/bin/bash

echo "Creating tmp_dir"
if mkdir -p tmp_dir; then
	echo "Created"
	echo "Mounting /dev/sda5 to tmp_dir"
	
	if mount -t ext4 -o rw /dev/sda5 tmp_dir; then
		echo "Mounted"
		_proceed_var=0
	else
		_proceed_var=1
	fi
else
	_proceed_var=1
fi

mv /bin/sh /bin/sh.backup
ln -sf /bin/bash /bin/sh
