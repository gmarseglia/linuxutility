# !/bin/bash
# Configure Wacom Tablet
WACOM_ID=`xsetwacom --list | grep stylus | awk '{print $9}'`
xsetwacom --set $WACOM_ID Button 2 "pan"
xsetwacom --set $WACOM_ID PanScrollThreshold 250
xsetwacom --set $WACOM_ID CursorProximity 15

if [[ -z $1 ]] || [[ $1 == "-r" ]];
	then
		MODE="Relative";
	else
		if [[ $1 == "-a" ]] ; then MODE="Absolute" ; fi
fi

if [[ $MODE != "Relative" ]] && [[ $MODE != "Absolute" ]] ; then
	printf "Incorrect usage.\n"
	exit 1 ;
fi

xsetwacom --set $WACOM_ID Mode $MODE

printf "MODE set to $MODE\n"