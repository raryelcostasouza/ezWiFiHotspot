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

CONFIG_FILE="$HOME/.ezWiFiHotspot/config.txt"
CONFIG_FOLDER="$HOME/.ezWiFiHotspot"
TMP_STATUS_HOTSPOT="/tmp/ezWiFiHotspot-status.txt"
TMP_OUTPUT_CREATE_AP="/tmp/output_create_ap.txt"
TMP_RESULT_CREATE_AP="/tmp/result_create_ap"

function errorMessage
{
    MESSAGE=$1
    zenity --error --title="Error" --no-wrap --text="$1"
}

function errorMessageDependency
{
    DEPENDENCY_NAME=$1
    PACKAGE_NAME=$2

    errorMessage "Missing Dependency '$DEPENDENCY_NAME'. Please install it before using this app.
    \n\nOn Ubuntu: sudo apt install $PACKAGE_NAME"
}

function clearTMPFiles
{
    rm -rf $TMP_STATUS_HOTSPOT
    rm -rf $TMP_RESULT_CREATE_AP
    $(sudo /opt/ezWiFiHotspot/util-root.sh "removeRootTMPFiles" $TMP_OUTPUT_CREATE_AP)
}

function getCurrentHotspotRunning
{
    #if there is a running hotspot there will an output string containing on the format (ap1)
    #saves the interface name to $TMP_STATUS_HOTSPOT
    #will be used when stopping the hotspot
    $(create_ap --list-running | grep -oP '\(\K[^\)]+' > $TMP_STATUS_HOTSPOT) | zenity --progress --pulsate --auto-close --text="Checking hotspot status..."
    echo $(cat $TMP_STATUS_HOTSPOT)
}

function loopCheckOutputCreateAP
{
    #check the output of create_ap for relevant information
    #until get an error or success
    #wait 0.5s between each check on the output file
    STOP="1"
    while [ $STOP = "1" ]
    do
        #give time for create_ap to setup the hotspot
        sleep 0.5

        #if the hotspot was started successfully there will be a line with AP-ENABLED
        local START_SUCCESS=$(cat $TMP_OUTPUT_CREATE_AP | grep -q AP-ENABLED; echo $?)
        if [ "$START_SUCCESS" = "0" ]
        then
            #if a line was found... can stop the checking loop
            STOP="0"
        else
            #if a line was not found... check if an error occurred
            local ERROR=$(cat $TMP_OUTPUT_CREATE_AP | grep ERROR)

            #if an error occurred the string will not be empty
            if [ ! -z "$ERROR" ]
            then
                #stop the loop
                STOP="0"
                errorMessage "Unable to start hotspot.\n\n$ERROR"
            fi
            #if no error occurred but not started hotspot yet wait again 0.5s
        fi
    done
    echo $START_SUCCESS > $TMP_RESULT_CREATE_AP
}

function checkIfHotspotStarted
{
    $(loopCheckOutputCreateAP) | zenity --progress --pulsate --auto-close --text="Starting hotspot..."
    echo $(cat $TMP_RESULT_CREATE_AP)
}

function start_hotspot
{
	#retrieve the first parameter given to the function
    INTERNET_NETWORK_INTERFACE=$1
    WIFI_INTERFACE=$2
    SSID=$3
    PASSWORD=$4

    $(sudo /opt/ezWiFiHotspot/util-root.sh "start_hotspot" $INTERNET_NETWORK_INTERFACE $WIFI_INTERFACE $SSID $PASSWORD $TMP_OUTPUT_CREATE_AP)

	if [ $(checkIfHotspotStarted) = "0" ]
	then
        #if the hotspot was successfully started
        zenity --info --no-wrap --title="Hotspot Started" --text="Hotspot Started\n\nConnection Info:\n\nSSID: $SSID\n\nPassword: $PASSWORD"
	fi
}

function stop_hotspot
{
    RUNNING_AP=$1
    $(sudo /opt/ezWiFiHotspot/util-root.sh "stop_hotspot" $RUNNING_AP) | zenity --progress --pulsate --auto-close --text="Stopping hotspot..."

    #if the something was returned it means the hotspot still running
    if [ -z "$(getCurrentHotspotRunning)" ]
    then
        zenity --info --title="Hotspot Stopped" --no-wrap --text="Hotspot stopped successfully"
    else
        #if there was a problem to start the hotspot
        zenity --error --title="Hotspot Stop Error" --no-wrap --text="Error! Unable to stop hotspot."
    fi
}

function checkDependencies
{
    if ! type zenity > /dev/null
    then
        echo "Missing dependency 'Zenity'. Please install it before using this script.
                \n\nFor Ubuntu: sudo apt install zenity
                \n\nFor Fedora: sudo dnf install zenity";
        exit 1
    fi

    if ! type create_ap > /dev/null
    then
        errorMessage "Missing Dependency 'create_ap'. Please install it before using this app.
        \n\nSearch for create_ap on the repositories of your distro or install directly from github.
        \n\nMore info at https://github.com/oblique/create_ap"
        exit 1
    fi

    if ! type ip > /dev/null
    then
        errorMessageDependency "ip" "iproute2"
        exit 1
    fi

    if ! type iw > /dev/null
    then
        errorMessageDependency "iw" "iw"
    fi

    if ! type hostapd > /dev/null
    then
        errorMessageDependency "hostapd" "hostapd"
        exit 1
    fi

    if ! type dnsmasq > /dev/null
    then
        errorMessageDependency "dnsmasq" "dnsmasq"
        exit 1
    fi

    if ! type iptables > /dev/null
    then
        errorMessageDependency "iptables" "iptables"
        exit 1
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

function checkConfigFileEmpty
{
    CONFIG_FILE=$1

    #if config file not exists
    if [ ! -f $CONFIG_FILE ]
    then
        #run the configuration interface
        zenity --info --title="ezWiFiHotspot - First run" \
                            --no-wrap --text="Press OK and follow the steps to set the network interfaces, ssid and password for your wifi hotspot."
        #create config folder and run configuration GUI
        mkdir -p $CONFIG_FOLDER
        $(/opt/ezWiFiHotspot/config.sh $CONFIG_FILE)
    fi
}

function windowMain
{
    CURRENT_AP=$(getCurrentHotspotRunning)

    #if CURRENT_AP not empty means hotspot is running
    if [ ! -z "$CURRENT_AP" ]
    then
        MSG="Status: Hotspot running"
        OPTIONS=("TRUE" "Stop")
    else
        MSG="Status: Hotspot not running"
        OPTIONS=("TRUE" "Start")
        OPTIONS+=("FALSE" "Settings")
    fi

    #if hotspot running show only option stop
    #otherwise show option start and change settings
    ACTION_SELECTED=$(zenity --list --radiolist --title="ezWiFiHotspot" \
                        --text="$MSG\n\nWhat would you like to do?\n" \
                        --column='' --column="Actions for WiFi Hotspot" \
                        --width=500 --height=300 \
                        "${OPTIONS[@]}")
    echo $ACTION_SELECTED
}

function runAction
{
    ACTION_SELECTED=$1
    CONFIG_FILE=$2

    case $ACTION_SELECTED in
        "Start" )
            #Load settings from config file
            INTERNET_NETWORK_INTERFACE=$(sed -n 1p $CONFIG_FILE)
            WIFI_INTERFACE=$(sed -n 2p $CONFIG_FILE)
            SSID=$(sed -n 3p $CONFIG_FILE)
            PASSWORD=$(sed -n 4p $CONFIG_FILE)

            start_hotspot $INTERNET_NETWORK_INTERFACE $WIFI_INTERFACE $SSID $PASSWORD
        ;;

        "Stop" )
            CURRENT_AP=$(cat $TMP_STATUS_HOTSPOT)
            stop_hotspot $CURRENT_AP
        ;;

        "Settings")
            $(/opt/ezWiFiHotspot/config.sh $CONFIG_FILE $CONFIG_FOLDER)
        ;;

    esac
}

clearTMPFiles
checkDependencies
checkSupportAPMode
checkConfigFileEmpty $CONFIG_FILE

LOOP="0"
while [ $LOOP = "0" ]
do
    ACTION_SELECTED=$(windowMain)
    runAction $ACTION_SELECTED $CONFIG_FILE
    #for stop/start hotspot the default action is to end the loop and finish the app

    #if the action is settings go back to main window after settings adjusted
    if [ "$ACTION_SELECTED" != "Settings" ]
    then
        LOOP="1"
    fi
done

clearTMPFiles
