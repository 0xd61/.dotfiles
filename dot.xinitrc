#
. ~/.xprofile

#primusrun glxinfo
# xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

# Mute Audio
#amixer sset Master mute

# Mute Microphone
#amixer sset Capture mute

# launch dbus
#if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
#	eval $(dbus-launch --exit-with-session --sh-syntax)
#fi
#systemctl --user import-environment DISPLAY XAUTHORITY

#if command -v dbus-update-activation-environment >/dev/null 2>&1; then
#        dbus-update-activation-environment DISPLAY XAUTHORITY
#fi

# launch dwm
#exec dwm
exec dbus-launch --sh-syntax --exit-with-session dwm
