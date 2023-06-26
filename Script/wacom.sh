#!/bin/bash

MODE_TO_SET=""

# Configure Wacom Tablet
WACOM_ID=`xsetwacom --list | grep stylus | awk '{print $9}'`
xsetwacom --set $WACOM_ID Button 2 "pan"
# xsetwacom --set $WACOM_ID Button 3 "button" "+3 -3"
xsetwacom --set $WACOM_ID PanScrollThreshold 250
# xsetwacom --set $WACOM_ID CursorProximity 15
# xsetwacom --set $WACOM_ID Area "2160 1300 19440 12100"

if [[ -z $1 ]] || ([[ $1 == '-s' ]] || [[ $1 == '--switch' ]]) ; then
	MODE_GET=$(xsetwacom --get $WACOM_ID Mode)
	if [[ $MODE_GET == "Relative" ]] ; then
		MODE_TO_SET="Absolute" ;
	else
		MODE_TO_SET="Relative" ;
	fi
fi

if [[ -z $MODE_TO_SET ]] && ([[ $1 == '-r' ]] || [[ $1 == '--relative' ]]) ; then
	MODE_TO_SET="Relative";
fi

if [[ -z $MODE_TO_SET ]] && ([[ $1 == '-a' ]] || [[ $1 == '--absolute' ]]) ; then
	MODE_TO_SET="Absolute";
fi

if [[ -z $MODE_TO_SET ]] ; then
	printf "Incorrect usage.\n"
	exit 1 ;
fi

#Adjust Graphic tablet rotation
xsetwacom --set $WACOM_ID Rotate half

xsetwacom --set $WACOM_ID Mode $MODE_TO_SET

notify-send "Mode of id:$WACOM_ID set to $MODE_TO_SET"
