#!/bin/bash

ifconfig eth0 up
udhcpc -t 5 -q -s "/bin/net_script.sh"
