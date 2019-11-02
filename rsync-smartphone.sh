#!/bin/bash

set -x

# rsync photos for Android devices connected in MTP mode

# Check for arguments before running script:

if  [ -z "$1"  ]; then
	echo
	echo "  $(basename $0) Error: No argument. Enter device name"
	echo
	echo "  Example: $(basename $0) Nexus-5x"
	echo
	exit 1
fi

DEVICE=$1
HOME="/home/${USER}"
ORIG=$(mount | grep gvfs | awk '{ print $3 }')
DEST="${HOME}/${DEVICE}"
[ ! -d $DEST ] && mkdir -p $DEST
cd $ORIG
cd *
CWD=$(pwd)

while read LINE; do
	cd "$CWD"
	mkdir -p "${DEST}/${LINE}"
	cd "$CWD/${LINE}"
	pwd
	# exclude ".Statuses" WhapsApp directory because rsync returns read errors failed verification
	rsync -av --exclude '*.Statuses*' . "${DEST}/${LINE}"
done < <(find . -maxdepth 3 -name 'WhatsApp' -o \
	-name 'DCIM' -o \
	-name 'Pictures' -type d)

# vim: ts=2 sw=2 noet ai nohls
