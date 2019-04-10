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
#This util-root.sh script contains the commands used by the ezWiFiHotspot.sh
#that need to be run as root user

ACTION=$1
case $ACTION in
    "start_hotspot")
            INTERNET_NETWORK_INTERFACE=$2
            WIFI_INTERFACE=$3
            SSID=$4
            PASSWORD=$5
            TMP_OUTPUT_CREATE_AP=$6

            create_ap $WIFI_INTERFACE $INTERNET_NETWORK_INTERFACE $SSID $PASSWORD &> $TMP_OUTPUT_CREATE_AP &
            ;;

    "stop_hotspot")
            RUNNING_AP=$2
            create_ap --stop $RUNNING_AP &> /dev/null 
            ;;

    "removeRootTMPFiles")
            TMP_OUTPUT_CREATE_AP=$2
            rm -rf $TMP_OUTPUT_CREATE_AP
            ;;
esac
