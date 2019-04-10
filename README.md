 ezWiFiHotspot
Simple and easy GUI for creating wifi hotspots on Linux using create_ap (https://github.com/oblique/create_ap) behind the scenes.

# New version 2.0 - 10/04/2019
https://github.com/raryelcostasouza/ezWiFiHotspot/releases/tag/v2.0
1. Configuration available entirely via GUI
2. Preliminary tests for dependencies and wifi board support
3. More detailed error messages

# Requirements
1. create_ap. Download and install from https://github.com/oblique/create_ap or from the deps subfolder on this repository.
2. dnsmasq
3. hostapd
4. iptables
5. ip
6. iw

on Ubuntu
sudo apt install dnsmasq hostapd iproute2 iw iptables

# Hardware support
WiFi board need to support AP-mode (access-point mode), essential to be able to create wifi hotspots.
Check running the following command on terminal:

$ iw list | grep AP

# About WiFi boards using proprietary drivers
Some proprietary wifi drivers do not support AP-mode (even when the wifi board actually supports it). In such case this app would not work.

# Installation instructions
sudo ./install.sh

Note: to enable non-admin users to create the wifi hotspot, by default, during the installation a rule is added to the /etc/sudoers file. This rule allow all users to execute the script /opt/ezWiFiHotspot/util-root.sh (where the root commands needed for managing the wifi hotspot are located).

# Screenshots

# Main Window (Hotspot not running)
![ss0](screenshots/shot0.png?raw=true "Main Window")

# Main Window (Hotspot running)
![ss1](screenshots/shot1.png?raw=true "Main Window")

# WiFi Hotspot created
![ss2](screenshots/shot2.png?raw=true "Hotspot Created")

# Settings GUI
![ss3](screenshots/shot4.png?raw=true "Settings")
![ss4](screenshots/shot5.png?raw=true "Settings")
![ss5](screenshots/shot6.png?raw=true "Settings")
![ss6](screenshots/shot7.png?raw=true "Settings")

## License

GNU GPL v3
