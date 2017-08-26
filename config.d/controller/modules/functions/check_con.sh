#!/bin/sh

if echo "$(emerge --version 2>/dev/null | tail -n 1)" | grep -q "$(uname -r)"; then
	exit 0
else
	exit 1
fi