 ezWiFiHotspot
Simple and easy GUI for creating wifi hotspots on Linux.

# Coming soon
1.Configuration entirely via GUI
2.More detailed error messages

# Requirements
1. create_ap (Download and install from https://github.com/oblique/create_ap)
2. dnsmasq
3. hostapd
4. net-tools (ifconfig)

on Ubuntu
sudo apt install dnsmasq hostapd net-tools

# About WiFi boards using proprietary drivers
It does not work. You need to use opensource drivers to be able to use the app.

# Hardware support
WiFi board need to support AP-mode.
Check running the following command on terminal:
$ iw list | grep AP

# Installation instructions
sudo ./install.sh

Note: to enable non-admin users to create the wifi hotspot, by default, during the installation a rule is added to the /etc/sudoers file. This rule allow all users to execute the script ezWiFiHotspot.sh (where the root commands needed for managing the wifi hotspot are located).

# Configuration

Before being used it is necessary to adjust a few settings. For now, editing manually the file /opt/ezWiFiHotspot/ezWiFiHotspot.sh

1) WIFI_INTERFACE=wlp2s0
Replace wlp2s0 with the desired wifi network interface to transmit the hotspot signal.
Check the ones available using the following command on terminal:
$ ifconfig

2) INTERNET_NETWORK_INTERFACE=enp3s0
Network interface that is connected to the internet. Usually enp3s0 for land connections and wlp2s0 for wifi boards.
NOTE: It can be the set the same as the WIFI_INTERFACE in case you want to share your wifi connection with a different ssid and password (only if 2.4Ghz wifi connection. It does not usually work for 5Ghz connections).
Check yours settings at:
$ ifconfig

3) PASSWORD
The default is set to "ezHotspot"

# Screenshots

## License

GNU GPL v3
