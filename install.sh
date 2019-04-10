#!/bin/bash

#dependencies

#install create_ap https://github.com/oblique/create_ap
#install wondershaper

#install net-tools (ubuntu) ifconfig
#install hostapd, dnsmasq

#sudo apt install wondershaper net-tools hostapd dnsmasq


#step 2
#edit the shortcut/hotspot-gui.sh with the correct wifi interface

LINE_SUDOERS="ALL ALL=NOPASSWD: /opt/ezWiFiHotspot/util-root.sh"

mkdir -p /opt/ezWiFiHotspot
cp -r app/* /opt/ezWiFiHotspot
cp shortcut/ezwifihotspot.desktop /usr/share/applications/

LINE_SUDOERS_EXISTS=$(cat /etc/sudoers | grep -q "$LINE_SUDOERS"; echo $?)

if [ "$LINE_SUDOERS_EXISTS" = "1" ]
then
    echo $LINE_SUDOERS >> /etc/sudoers
fi
