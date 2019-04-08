function errorMessage
{
    MESSAGE=$1
    zenity --error --title="Error" --no-wrap --text="$1"
}

function windowSelectNetworkInterface
{
  TITLE=$1
  MSG=$2
  getListNetworkInterfaces

  TABLE_SELECTION=$(cat /tmp/table_interfaces.txt)
  INTERFACE_SELECTED=$(zenity --list --radiolist --title="$TITLE" \
                      --text="$MSG" \
                      --column='' --column="Network Interfaces" \
                      --width=500 --height=250 \
                      $TABLE_SELECTION)
  echo $INTERFACE_SELECTED
}

function windowSelectInternetNetworkInterface
{
    TITLE="Internet Network Interface"
    MSG="Please select the network interface that is connected to the internet:\n"
    echo $(windowSelectNetworkInterface $TITLE $MSG)
}

function windowSelectWiFiNetworkInterface
{
    TITLE="WiFi Network Interface"
    MSG="Please select your WiFi network interface for the hotspot:\n"
    echo $(windowSelectNetworkInterface $TITLE $MSG)
}

function getListNetworkInterfaces
{
    rm -rf /tmp/table_interfaces.txt
    LIST_NETWORK_INTERFACES=$(ip -o link show | grep -v lo | awk -F': ' '{print $2}')

    for INTERFACE in $LIST_NETWORK_INTERFACES
    do
      echo "FALSE $INTERFACE" >> /tmp/table_interfaces.txt
    done
}

function windowCreateWiFiPassword
{
    PASSWORD=$(zenity --entry --title="Create WiFi Password" \
                              --text "What password should be used for the hotspot?")
    echo $PASSWORD
}

function windowCreateSSID
{
  SSID=""
  while [ -z $SSID ]
  do
    SSID=$(zenity --entry --title="Select WiFi Name (SSID)" \
                          --text "What name should be used for the hotspot?")
  done

  echo $SSID
}

INTERNET_INTERFACE=$(windowSelectInternetNetworkInterface)
WIFI_INTERFACE=$(windowSelectWiFiNetworkInterface)
SSID=$(windowCreateSSID)
PASSWORD=$(windowCreateWiFiPassword)

echo $INTERNET_INTERFACE > config.txt
echo $WIFI_INTERFACE >> config.txt
echo $SSID >> config.txt
echo $PASSWORD >> config.txt
