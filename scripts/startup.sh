#!/usr/bin/env bash

# This script is sourced from .bashrc at boot and ssh session start
# to select the user's selected start-up option.
# dave crump 20170413

############ Set Environment Variables ###############

PATHSCRIPT=/home/pi/rpidatv/scripts
PATHRPI=/home/pi/rpidatv/bin
CONFIGFILE=$PATHSCRIPT"/rpidatvconfig.txt"
PATHCONFIGS="/home/pi/rpidatv/scripts/configs"  ## Path to config files

############ Function to Read from Config File ###############

get_config_var() {
lua - "$1" "$2" <<EOF
local key=assert(arg[1])
local fn=assert(arg[2])
local file=assert(io.open(fn))
for line in file:lines() do
local val = line:match("^#?%s*"..key.."=(.*)$")
if (val ~= nil) then
print(val)
break
end
end
EOF
}

######################### Start here #####################

# Determine if this is a user ssh session, or an autoboot
case $(ps -o comm= -p $PPID) in
  sshd|*/sshd)
    SESSION_TYPE="ssh"
  ;;
  login)
    SESSION_TYPE="boot"
  ;;
  *)
    SESSION_TYPE="ssh"
  ;;
esac

# If gui is already running and this is an ssh session
# stop the gui, start the menu and return
ps -cax | grep 'rpidatvgui' >/dev/null 2>/dev/null
RESULT="$?"
if [ "$RESULT" -eq 0 ]; then
  if [ "$SESSION_TYPE" == "ssh" ]; then
    killall rpidatvgui
    /home/pi/rpidatv/scripts/menu.sh menu
  fi
  return
fi

# If menu is already running, exit to command prompt
ps -cax | grep 'menu.sh' >/dev/null 2>/dev/null
RESULT="$?"
if [ "$RESULT" -eq 0 ]; then
  return
fi

# So continue assuming that this could be a first-start

# If pi-sdn is not running, check if it is required to run
ps -cax | grep 'pi-sdn' >/dev/null 2>/dev/null
RESULT="$?"
if [ "$RESULT" -ne 0 ]; then
  if [ -f /home/pi/.pi-sdn ]; then
    . /home/pi/.pi-sdn
  fi
fi

# Facility to Disable WiFi
# Calls .wifi_off if present and runs "sudo ifconfig wlan0 down"
if [ -f ~/.wifi_off ]; then
    . ~/.wifi_off
fi

# If framebuffer copy is not already running, start it
ps -cax | grep 'fbcp' >/dev/null 2>/dev/null
RESULT="$?"
if [ "$RESULT" -ne 0 ]; then
  fbcp &
fi

# If a boot session, set up a loop to wait for a valid IP address
COUNT=0
if [ "$SESSION_TYPE" == "boot" ]; then
  COUNT=4 # Increase this value if network is slow
fi

while [ "$COUNT" -gt 0 ]
do
  # Check the IP Address (or addresses if Wifi Connected as well)
  IP1=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | sed -n 1p)
  IP2=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | sed -n 2p)
  if [ "${#IP1}" -le 1 ] ; then
    IPCaption="Not connected"
  else
    IPCaption="IP "$IP1" "$IP2
  fi

  # Create a BATC Splash screen with the IP Address displayed
  rm /home/pi/rpidatv/scripts/images/BATC_IP_Splash.png >/dev/null 2>/dev/null
  convert /home/pi/rpidatv/scripts/images/BATC_Black.png\
   -gravity South -pointsize 25 -fill "rgb(255,255,255)"\
   -annotate 0 "$IPCaption"\
   /home/pi/rpidatv/scripts/images/BATC_IP_Splash.png

  # Put up the Splash Screen, and then kill the process
  sudo fbi -T 1 -noverbose -a /home/pi/rpidatv/scripts/images/BATC_IP_Splash.png >/dev/null 2>/dev/null
  (sleep 1; sudo killall -9 fbi >/dev/null 2>/dev/null) &  ## kill fbi once it has done its work
  sleep 2
  let "COUNT -= 1"
done

# Read the desired start-up behaviour
MODE_STARTUP=$(get_config_var startup $CONFIGFILE)

# Select the appropriate action

case "$MODE_STARTUP" in
  Prompt)
    # Go straight to command prompt
    return
  ;;
  Console)
    # Start the menu if this is an ssh session
    if [ "$SESSION_TYPE" == "ssh" ]; then
      /home/pi/rpidatv/scripts/menu.sh menu
    fi
    return
  ;;
  Display)
    # Old option to be deprecated
    return
  ;;
  Button)
    # Old option to be deprecated
    return
  ;;
  TX_boot)
    # Flow will only have got here if menu not already running
    # So start menu in immediate transmit mode
    /home/pi/rpidatv/scripts/menu.sh
    return
  ;;
  Display_boot)
    #
    /home/pi/rpidatv/bin/rpidatvgui
    return
  ;;
  Button_boot)
    # If this is on boot, start the button listener
    if [ "$SESSION_TYPE" == "boot" ]; then
      /home/pi/rpidatv/scripts/rpibutton.sh
    fi
    return
  ;;
  *)
    return
  ;;
esac
