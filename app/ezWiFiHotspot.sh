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
	#retrieve the first parameter given to the function
  INTERNET_NETWORK_INTERFACE=$1
  WIFI_INTERFACE=$2
  SSID=$3
  PASSWORD=$4

	create_ap $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $SSID $PASSWORD > /dev/null&

	if [ "$(check_hotspot_status 10 "Starting")" = "on" ]
	then
        #if the hotspot was successfully started
        zenity --info --no-wrap --title="Hotspot Started" --text="Hotspot Started\n\nConnection Info:\n\nSSID: $SSID\n\nPassword: $PASSWORD"
    else
        #if there was a problem to start the hotspot
        ERROR_MSG=$(cat /tmp/log_create_ap | grep ERROR)
        errorMessage "Unable to start hotspot.\n\n$ERROR_MSG"
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

function checkSupportAPMode
{
    #check if wifi board supports AP (access point mode)
    SUPPORT_AP_MODE=$(iw list | grep -q AP)
    if [ $SUPPORT_AP_MODE ]
    then
        errorMessage "Your wifi board does not support AP mode.\nIt cannot be used to create wifi hotspots."
        exit 1
    fi
}

function errorMessage
{
    MESSAGE=$1
    zenity --error --title="Error" --no-wrap --text="$1"
}
#Load settings from config file
INTERNET_NETWORK_INTERFACE=$(sed -n 1p config.txt)
WIFI_INTERFACE=$(sed -n 2p config.txt)
SSID=$(sed -n 3p config.txt)
PASSWORD=$(sed -n 4p config.txt)


checkSupportAPMode
then

  #if the variable hotspot_network_interface is empty means that the hotspot is currently not running
  if [ "$(check_hotspot_status 0 "Nothing")" = "off" ]
  then
      #hotspot not running... so start it
      start_hotspot $INTERNET_NETWORK_INTERFACE $WIFI_INTERFACE $SSID $PASSWORD
  else
      #hotspot running... ask what to do... restart or stop?
      zenity --question --no-wrap --title="Hotspot already running" --text="The hotspot is currently running.\n\What would you like to do?" --ok-label="Restart Hotspot" --cancel-label="Stop Hotspot"

      #if the user selected the yes option (Restart hotspot)
      if [ "$?" = "0" ]; then
          create_ap --stop ap0
          start_hotspot $INTERNET_NETWORK_INTERFACE $WIFI_INTERFACE $SSID $PASSWORD
      else
          #just stop it
          stop_hotspot
      fi
  fi

else
    errorMessage "NOT CONFIGURED"
fi
