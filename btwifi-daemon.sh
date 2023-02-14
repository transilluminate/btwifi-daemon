#!/bin/bash
# Copyright 2023 Adrian Robinson <adrian.j.robinson at gmail dot com>
# https://github.com/transilluminate/btwifi-daemon
#
# add this to the bottom of /etc/rc.local:
# /path/to/btwifi-daemon.sh &

# location of the config file (include absolute path)
CONFIG_FILE="btwifi-daemon.config"

# load external config file for login details
if [ -e $CONFIG_FILE ]; then
	source $CONFIG_FILE
else
	echo "Config file does not exist!"
	echo "Please see ${CONFIG_FILE}.example for hints"
	exit 1
fi

DEBUG=false
INTERFACE=wlan0
SERVER="https://www.btwifi.com:8443"
DELAY_INTERFACE=2       # number of seconds to see if the interface is up / connected to the access point
DELAY_LOGIN_ATTEMPTS=5  # additional delay between login attempts
DELAY_SUCCESS=60        # when things are going well, slow down

# Check if terminal allows output, if yes, define colors for output
if [[ -t 1 ]]; then			# check we're on a console
	ncolors=$(tput colors)
	if [[ -n $ncolors && $ncolors -ge 8 ]]; then
		red=$(tput setaf 1)    # ANSI red
		green=$(tput setaf 2)  # ANSI green
		nc=$(tput sgr0)        # (N)o (C)olor
	else
		red=''; green=''; nc=''
	fi
fi

while true; do
	if [[ $(iwgetid $INTERFACE) && $(iwgetid -r $INTERFACE) == "BTWi-fi" ]]; then
		if [[ "$DEBUG" = true ]]; then echo "${green}Info: You're connected to 'BTWi-fi' access point${nc}"; fi
		serverResponse=$(wget -qO - --no-check-certificate --no-cache --timeout 5 "$SERVER/home")
		isLoggedIn=$(echo $serverResponse | grep -c "now logged on to BT Wi-Fi")
		if [[ $isLoggedIn > 0 ]]; then
			if [[ "$DEBUG" = true ]]; then echo "${green}Info: You're logged in to BTWi-fi!${nc}"; fi
			if [[ "$DEBUG" = true ]]; then echo "Info: Sleeping for $DELAY_SUCCESS seconds..."; fi
			sleep $DELAY_SUCCESS
		else
			if [[ "$DEBUG" = true ]]; then echo "${red}Info: You're not logged in to BTWi-fi${nc}"; fi
		 	if [[ "$DEBUG" = true ]]; then echo "Info: Attempting login"; fi
			serverResponse=$(wget -qO - --no-check-certificate --no-cache --post-data "username=$USERNAME&password=$PASSWORD" "$SERVER/tbbLogon")
			isAuthenticated=$(echo $serverResponse | grep -c "now logged on")
			if [[ $isAuthenticated > 0 ]]; then
				if [[ "$DEBUG" = true ]]; then echo "${green}Success: Authenticating to BTWi-fi was successful!${nc}"; fi
				if [[ "$DEBUG" = true ]]; then logger -t btwifi "Success: Authenticating to BTWi-fi was successful"; fi
				if [[ "$DEBUG" = true ]]; then echo "Info: Sleeping for $DELAY_SUCCESS seconds..."; fi
				sleep $DELAY_SUCCESS
			else
				if [[ "$DEBUG" = true ]]; then echo "${red}Error: Authenticating to BTWi-fi was unsuccessful${nc}"; fi
				if [[ "$DEBUG" = true ]]; then echo "Info: Sleeping for $DELAY_LOGIN_ATTEMPTS seconds..."; fi
				sleep $DELAY_LOGIN_ATTEMPTS
			fi
		fi
	else
		if [[ "$DEBUG" = true ]]; then echo "${red}Error: You're not connected to 'BTWi-fi' access point${nc}"; fi
		if [[ "$DEBUG" = true ]]; then echo "Info: Sleeping for $DELAY_INTERFACE seconds..."; fi
		sleep $DELAY_INTERFACE
	fi
done
