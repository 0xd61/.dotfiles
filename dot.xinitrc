#
monitor.sh dark

# turn off sound
amixer set Master mute

while true; do
	~/.dwm-status/status.mksh
	sleep 10
done &

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

exec dwm
