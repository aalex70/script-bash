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
FOUND="$(find $ORIG -maxdepth 1 -name 'mtp*' -type d | wc -l)"
if [ $FOUND -eq 0 ];then
	echo "Error: Device not found - File system gvfs not mounted"
	exit 10
elif [ $FOUND -gt 1 ];then
	echo "Error: Found $FOUND devices"
	echo "Disconect one or more devices; you must have only one connected device"
	exit 11
elif [ $FOUND -eq 1 ];then
	echo "OK: Found $FOUND devices"
fi
cd $ORIG
cd mtp*
CWD=$(pwd)

while read LINE; do
	cd "$CWD"
	mkdir -p "${DEST}/${LINE}"
	cd "$CWD/${LINE}"
	pwd
	# exclude ".Statuses" WhapsApp directory because rsync returns read errors failed verification
	rsync -av --exclude '*.Statuses*' --exclude '.thumbnails' --exclude '.aux' --exclude '*.db.crypt*' . "${DEST}/${LINE}"
done < <(find . -maxdepth 3 -name 'WhatsApp' -o \
	-name 'DCIM' -o \
	-name 'Music' -o \
	-name 'Screenshots' -o \
	-name 'Video' -o \
	-name 'Pictures' -type d)

# vim: ts=2 sw=2 noet ai nohls
