#!/usr/bin/env bash
#https://www.reddit.com/r/Dell/comments/6s2e3w/optimizing_dell_xps_for_linux/
#https://www.reddit.com/r/Dell/comments/6s2e3w/optimizing_dell_xps_for_linux/dla56m5/
#https://wiki.ubuntu.com/Kernel/PowerManagement/PowerSavingTweaks
#https://www.kernel.org/doc/html/latest/admin-guide/laptops/laptop-mode.html
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cp $DIR/xps_power.sh /usr/local/bin/xps_power.sh
ln -s $DIR/xps_power.rules /etc/udev/rules.d/99-xps-power.rules
cp $DIR/xps_power.service /etc/systemd/system/xps-power.service
ln -s $DIR/xps_power.conf /etc/sysctl.d/99-xps-power.conf
ln -s $DIR/i915.conf /etc/modprobe.d/i915.conf
ln -s $DIR/audo_powersave.conf /etc/modprobe.d/auto_powersave.conf
ln -s $DIR/iwldvm.conf /etc/modprobe.d/iwldvm.conf

# to apply kernel module config
update-initramfs -u -k all

chmod +x /usr/local/bin/xps_power.sh
systemctl enable xps-power.service

