# !/bin/bash

DONE_MESS="AutoUpdate.sh Done"

autoUpdate.sh
notify-send $DONE_MESS
printf "$DONE_MESS.\nQuit? (y/n)\n"
read response
if [[ $response = 'y' ]] || [[ $response = 'Y' ]] ; then
	exit;
fi