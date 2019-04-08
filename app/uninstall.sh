#!/bin/bash

#uninstall script for ezWiFiHotspot
#must be executed as ROOT

#remove the line added to sudoers file during install
sed -i '/ezWiFiHotspot/d' /etc/sudoers

sudo rm -f /usr/share/applications/ezwifihotspot.desktop
sudo rm -rf /opt/ezWiFiHotspot
