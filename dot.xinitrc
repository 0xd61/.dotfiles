#
monitor.sh dark


while true; do
	~/.dwm-status/status.mksh
	sleep 10
done &

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

start-pulseaudio-x11 &

# Mute Audio
pactl set-sink-mute 0 1

# Mute Microphone
pactl set-source-mute 1 1

exec dwm
