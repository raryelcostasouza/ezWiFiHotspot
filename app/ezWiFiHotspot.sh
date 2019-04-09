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

CONFIG_FILE="/opt/ezWiFiHotspot/config.txt"

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

	create_ap $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $SSID $PASSWORD &> /tmp/log_create_ap

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

function checkConfigFileEmpty
{
    CONFIG_FILE=$1

    #if config file not exists
    if [ ! -f $CONFIG_FILE ]
    then
        #run the configuration interface
        zenity --info --title="ezWiFiHotspot - First run" \
                            --no-wrap --text="Press OK and follow the steps to set the network interfaces, ssid and password for your wifi hotspot."
        $(sudo /opt/ezWiFiHotspot/config.sh $CONFIG_FILE)
    fi
}

function windowMain
{
    #test if hotspot is running
    HOTSPOT_STATUS="$(check_hotspot_status 0 "Nothing")"

    if [ "$HOTSPOT_STATUS" = "on" ]
    then
        MSG="Status: Hotspot stopped"
        OPTIONS="TRUE" "Stop wifi hotspot"
    else
        MSG="Status: Hotspot running"
        OPTIONS=("TRUE" "Start wifi hotspot")
        #OPTION2="FALSE" "Change settings"
    fi

    #if hotspot running show only option stop
    #otherwise show option start and change settings
    ACTION_SELECTED=$(zenity --list --radiolist --title="ezWiFiHotspot" \
                        --text="$MSG\nWhat would you like to do?\n" \
                        --column='' --column="Actions" \
                        --width=500 --height=300 \
                        $OPTIONS)
    echo $ACTION_SELECTED
}

function runAction
{
    ACTION_SELECTED=$1
    CONFIG_FILE=$2

    if [ $ACTION_SELECTED = "Start wifi hotspot" ]
    then
        #Load settings from config file
        INTERNET_NETWORK_INTERFACE=$(sed -n 1p $CONFIG_FILE)
        WIFI_INTERFACE=$(sed -n 2p $CONFIG_FILE)
        SSID=$(sed -n 3p $CONFIG_FILE)
        PASSWORD=$(sed -n 4p $CONFIG_FILE)

        start_hotspot $INTERNET_NETWORK_INTERFACE $WIFI_INTERFACE $SSID $PASSWORD
    elif [ $ACTION_SELECTED = "Stop wifi hotspot" ]
    then
        stop_hotspot
    elif [ $ACTION_SELECTED = "Change settings" ]
    then
        $(sudo /opt/ezWiFiHotspot/config.sh $CONFIG_FILE)
    fi
}


checkSupportAPMode
checkConfigFileEmpty $CONFIG_FILE
ACTION_SELECTED=$(windowMain)
runAction $ACTION_SELECTED $CONFIG_FILE
