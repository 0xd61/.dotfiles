#
while true; do
	~/.dwm-status/status.mksh
	sleep 10
done &

#primusrun glxinfo
# xrandr --setprovideroutputsource modesetting NVIDIA-0
# xrandr --auto

# Mute Audio
amixer sset Master mute

# Mute Microphone
amixer sset Capture mute

# launch dwm with dbus
exec dbus-launch --sh-syntax --exit-with-session dwm
