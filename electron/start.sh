#!/bin/bash

## Initalizing code
# Echo the localhost value into the hosts file
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

# By default docker gives us 64MB of shared memory size but we need more!
umount /dev/shm && mount -t tmpfs shm /dev/shm

rm /tmp/.X0-lock &>/dev/null || true


# Remove any temp data stored for X Org
rm /tmp/.X0-lock &>/dev/null || true

# Check to see if the noVNC_PASSWORD has been set
if [[ -z "${NOVNC_PASSWORD}" ]]; then
      while :; do
            echo -e "\e[33mThe \$NOVNC_PASSWORD variable is empty and needs to be set\e[0m"
            sleep 30
      done
fi

# Set the X11VNC Password
mkdir ~/.x11vnc
x11vnc -quiet -storepasswd ${NOVNC_PASSWORD} ~/.x11vnc/passwd

export DISPLAY=:0
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
echo "Starting X in 2 seconds"
sleep 2
startx -- -nocursor  &
P1=$!
x11vnc -find -quiet -forever -localhost -rfbauth ~/.x11vnc/passwd &
P2=$!

wait ${P1} ${P2}

while :
do
	echo "startx failed, so we will just wait here while you debug!"
	sleep 30
done

