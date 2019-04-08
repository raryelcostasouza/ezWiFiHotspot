#!/bin/bash

#Copyright (C) 2019 Raryel C. Souza <raryel.costa at gmail.com>

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
# any later version

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#ezWiFiHotspot - https://github.com/raryelcostasouza/ezWiFiHotspot

#SETTINGS SECTION ------------------------------------------------
WIFI_INTERFACE=wlp2s0
PASSWORD=ezHotspot

#network interface that is connected to the internet
INTERNET_NETWORK_INTERFACE=enp3s0

#END OF SETTINGS SECTION ------------------------------------------------

function check_hotspot_status
{
    WAIT_TIME=$1
    OPERATION=$2

    sleep $WAIT_TIME | zenity --progress --pulsate --auto-close --text="$OPERATION hotspot..."
    AP0_INTERFACE=$(ifconfig | grep ap0)


    #if the hotspot is active the string will be not empty
    if [ -z "$AP0_INTERFACE" ]
    then
        echo "off"
    else
        echo "on"
    fi
}


function start_hotspot
{
	SSID=`hostname`"-HOTSPOT"

	#retrieve the first parameter given to the function
	WIFI_INTERFACE=$1
  INTERNET_NETWORK_INTERFACE=$2
  PASSWORD=$3

	create_ap $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $SSID $PASSWORD > /dev/null&

	if [ "$(check_hotspot_status 5 "Starting")" = "on" ]
	then
        #if the hotspot was successfully started
        zenity --info --title="Hotspot Started" --text="Hotspot Started\n\nConnection Info:\n\nSSID: $SSID\n\nPassword: $PASSWORD"
    else
        #if there was a problem to start the hotspot
        zenity --error --title="Hotspot Error" --text="Unable to start hotspot. Please contact the admin."
	fi
}

function stop_hotspot
{
    create_ap --stop ap0

    if [ "$(check_hotspot_status 5 "Stopping")" = "off" ]
    then
        zenity --info --title="Hotspot Stopped" --text="Hotspot stopped successfully"
    else
        #if there was a problem to start the hotspot
        zenity --error --title="Hotspot Stop Error" --text="Error! Unable to stop hotspot."
    fi
}

#retrieve the first parameter passed to the script
WIFI_INTERFACE_EXISTS=$(ifconfig | grep $WIFI_INTERFACE)

#if the wifi interface parameter is missing or invalid
if [ -z "$WIFI_INTERFACE_EXISTS" ]
then
    zenity --error --title="Invalid Parameter" --text="Invalid Wifi interface: $WIFI_INTERFACE.\n\nPlease provide a valid wifi interface as a parameter to the script."
else
    #if the wifi interface is valid
    #if the variable hotspot_network_interface is empty means that the hotspot is currently not running
    if [ "$(check_hotspot_status 0 "Nothing")" = "off" ]
    then
        #hotspot not running... so start it
        start_hotspot $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $PASSWORD
    else
        #hotspot running... ask what to do... restart or stop?
        zenity --question --title="Hotspot already running" --text="The hotspot is currently running.\n\What would you like to do?" --ok-label="Restart Hotspot" --cancel-label="Stop Hotspot"

        #if the user selected the yes option (Restart hotspot)
        if [ "$?" = "0" ]; then
            create_ap --stop ap0
            start_hotspot $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $PASSWORD
        else
            #just stop it
            stop_hotspot
        fi
    fi
fi
