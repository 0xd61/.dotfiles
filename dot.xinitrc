#

# reduce backlight
xbacklight -set 3

# turn off sound
amixer set Master mute

while true; do
	~/.dwm-status/status.mksh
	sleep 5
done

exec dwm
