TMP_LIST="/tmp/list_network_interfaces.txt"

function errorMessage
{
    MESSAGE=$1
    zenity --error --title="Error" --no-wrap --text="$1"
}

function windowSelectNetworkInterface
{
  TITLE=$1
  MSG=$2
  TMP_LIST=$3

  TABLE_SELECTION=$(cat $TMP_LIST)
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
    TMP_LIST=$1
    getListActiveNetworkInterfaces $TMP_LIST
    echo $(windowSelectNetworkInterface "$TITLE" "$MSG" $TMP_LIST)
}

function windowSelectWiFiNetworkInterface
{
    TITLE="WiFi Network Interface"
    MSG="Please select your WiFi network interface for the hotspot:\n"
    TMP_LIST=$1
    getListWiFiNetworkInterfaces $TMP_LIST
    echo $(windowSelectNetworkInterface "$TITLE" "$MSG" $TMP_LIST)
}

function generateRadioList
{
    TMP_LIST=$1
    LIST_INTERFACES=$2

    rm -rf $TMP_LIST
    for INTERFACE in $LIST_INTERFACES
    do
      echo "FALSE $INTERFACE" >> $TMP_LIST
    done
}

function getListActiveNetworkInterfaces
{
    TMP_LIST=$1
    #list of all active network interfaces
    LIST_NETWORK_INTERFACES=$(ip -o link show | grep -v DOWN | grep -v lo | awk -F': ' '{print $2}')
    generateRadioList $TMP_LIST "$LIST_NETWORK_INTERFACES"
}

function getListWiFiNetworkInterfaces
{
    TMP_LIST=$1
    LIST_WIFI_INTERFACES=$(iw dev | awk '$1=="Interface"{print $2}')
    generateRadioList $TMP_LIST "$LIST_WIFI_INTERFACES"
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

function windowCreateWiFiPassword
{
    PASSWORD=$(zenity --entry --title="Create WiFi Password" \
                              --text "What password should be used for the hotspot?")
    echo $PASSWORD
}

INTERNET_INTERFACE=$(windowSelectInternetNetworkInterface $TMP_LIST)
WIFI_INTERFACE=$(windowSelectWiFiNetworkInterface $TMP_LIST)
SSID=$(windowCreateSSID)
PASSWORD=$(windowCreateWiFiPassword)
CONFIG_FILE=$1

#save the settings to the config file
echo $INTERNET_INTERFACE > $CONFIG_FILE
echo $WIFI_INTERFACE >> $CONFIG_FILE
echo $SSID >> $CONFIG_FILE
echo $PASSWORD >> $CONFIG_FILE
