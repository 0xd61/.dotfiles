#!/usr/bin/env bash
#
# Control the monitor backlight and color temperature
# requires `xbacklight`, `xrandr`, and `redshift`
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: June 25, 2018
# License: MIT

shopt -s extglob

usage() {
	local prog=${0##*/}
	cat <<-EOF
	Usage: $prog [ bright | dark | brighter | darker | darkest | night | day | [0-9]+ ]
	Usage: $prog [ mirror | laptop | hdmi ]

	Examples:
	  # Set output(s)
	  $prog mirror # mirror display and HDMI
	  $prog laptop # laptop display only
	  $prog hdmi   # hdmi output only

	  # Modify color temperature for night (4500k)
	  $prog night

	  # Make the screen the darkest it will go
	  $prog darkest

	  # Get the current brightness level
	  $prog get

	  # Manually set the brightness (out of 100)
	  $prog 75
	EOF
}

CALL="/sys/class/backlight/intel_backlight/brightness"
MAX=$(cat /sys/class/backlight/intel_backlight/max_brightness)
CURRENT=$(cat ${CALL})

case "$1" in
	mirror|dual) xrandr --output eDP1 --auto --output HDMI1 --set 'Broadcast RGB' 'Limited 16:235' --auto;;
	hdmi|external) xrandr --output eDP1 --off --output HDMI1 --set 'Broadcast RGB' 'Limited 16:235' --auto;;
	laptop|builtin) xrandr --output HDMI1 --off --output eDP1 --auto;;

	brighter) sudo tee $CALL <<< $(($CURRENT + 50));;
	darker) sudo tee $CALL <<< $(($CURRENT - 50));;

	bright|brightest) sudo tee $CALL <<< $(($MAX - 500));;
	dark) sudo tee $CALL <<< 200;;
	darkest) sudo tee $CALL <<< 1;;

	day) redshift -m randr -x;;
	night) redshift -m randr -PO 4500;;

	(+([0-9])) sudo tee $CALL <<< "$1";;
	''|get) echo $CURRENT;;

	-h|help) usage;;
	*) usage >&2; exit 1;;
esac

