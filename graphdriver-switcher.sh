#!/bin/bash

for i in "$@"
do
case $i in
	devicemapper)
		GRAPHDRIVER=devicemapper
	;;
	aufs)
		GRAPHDRIVER=aufs
	;;
	overlay)
		GRAPHDRIVER=overlay
	;;
	overlay2)
		GRAPHDRIVER=overlay2
	;;
	*)
		GRAPHDRIVER=overlay2
	;;
esac	
done

echo "Switching graphdriver to $GRAPHDRIVER"

# switch graphdriver
systemctl stop docker
if grep -F "storage-driver=" /lib/systemd/system/docker.service ;
then
	# found storage driver, delete this entry and add a new one for devicemapper
	echo "Found storage driver, proceeding to change it"
	sed -i "s/--storage-driver=\w\+/--storage-driver=$GRAPHDRIVER/" /lib/systemd/system/docker.service
else
	# looks for exec start, if it is there, append this, if not then add it
	echo "Didn't find storage-driver, appending a new one"

	if grep -F "ExecStart=" /lib/systemd/system/docker.service;
	then
		sed -i "/^ExecStart/ s/$/ --storage-driver=$GRAPHDRIVER/" /lib/systemd/system/docker.service
	else
		echo "ExecStart=/usr/bin/dockerd -H fd:// --storage-driver=$GRAPHDRIVER" >> /lib/systemd/system/docker.service
	fi
	
fi
systemctl daemon-reload
systemctl start docker
