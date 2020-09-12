#!/bin/bash
#Needed for (!pci*)
shopt -s extglob

#Due to the summer heat, changed "status=ac" to "status=coolac"

{
#Adapted from:
#http://www.neowin.net/forum/topic/1106745-howto-powersaving-tweaks-with-a-udev-rule/
#https://wiki.archlinux.org/index.php/Power_management

#Called by:
#/etc/udev/rules.d/power.rules

#More powersaving settings are in:
#/boot/EFI/refind/refind.conf (kernel line)

set -e # Stop on errors

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: not running with root permissions."
  echo "Please run as root!"
  exit 1
fi

#Delay... this is needed because sometimes the files do not update as fast as needed
if [ "$1" != "status" ]; then
  sleep 3s
fi

#Automatically check ac/bat status
if [ -e /sys/class/power_supply/AC/online ]; then
  if [ `cat /sys/class/power_supply/AC/online` == "1" ]; then
    status="coolac"
  else
    status="battery"
  fi
else
  case `cat /sys/class/power_supply/BAT0/status` in
    Charging)
      status="coolac"
    ;;
    Discharging)
      status="battery"
    ;;
    Full)
      status="coolac"
    ;;
    *)
      status=`cat /sys/class/power_supply/BAT0/status`
    ;;
  esac
fi

newoutf() { #Function to output the status of files
  case $status in
    ac)
      okValue=${2}
      badValue=${3}
    ;;
    battery)
      okValue=${3}
      badValue=${2}
    ;;
    *)
      okValue=-whoknows
      badValue=-whoknows
    ;;
  esac
  echo Expected "'${1}'" value: ${okValue}

  NokValues=0
  NbadValues=0
  NunknValues=0

  for i in ${1}; do
    value=`cat ${i}`

    case "$value" in
    "$okValue")
      NokValues=$((NokValues+1)) #Number of OK Values
      if [ ! -z ${4} ]; then
        echo -e "    "${i} ":" "\e[7;32m${value}\e[0m"
      fi
    ;;
    "$badValue")
      NbadValues=$((NbadValues+1)) #Number of BAD Values
      echo -e "    "${i} ":" "\e[7;31m${value}\e[0m"
    ;;
    *)
      NunknValues=$((NunknValues+1)) #Number of UNKNOWN Values
      echo -e "    "${i} ":" "\e[7;34m${value}\e[0m"
    ;;
    esac
  done

  NtotValues=$((NokValues + NbadValues + NunknValues))

  if [ ${NokValues} == ${NtotValues} ]; then
  echo -e "    ALL values OK:" "\e[7;32m${NokValues}\e[0m / ${NtotValues}"
  else
    if [ ${NbadValues} != 0 ]; then
      echo -e "    BAD values:" "\e[7;31m${NbadValues}\e[0m / ${NtotValues}"
    fi
    if [ ${NunknValues} != 0 ]; then
      echo -e "    UNKNOWN values:" "\e[7;34m${NunknValues}\e[0m / ${NtotValues}"
    fi
  fi
}

if [ "$1" == "status" ]; then #Report status
  echo -e "Current status: " ${status}

  echo -e "\e[7mCPU PSTATE settings\e[0m"
  newoutf "/sys/devices/system/cpu/intel_pstate/min_perf_pct" 25 5
  newoutf "/sys/devices/system/cpu/intel_pstate/max_perf_pct" 100 80
  newoutf "/sys/devices/system/cpu/intel_pstate/no_turbo" 0 1
  newoutf "/sys/devices/system/cpu/cpu?/cpufreq/energy_performance_preference" balance_performance balance_power

  echo -e "\e[7mDevice, disk and USB runtime PM\e[0m"
  newoutf "/sys/bus/*/devices/*/power/control" on auto
  newoutf "/sys/bus/*/devices/*/ata*/power/control" on auto
  newoutf "/sys/block/*/device/power/control" on auto

  echo -e "\e[7mUSB autosuspend\e[0m"
  newoutf "/sys/bus/usb/devices/*/power/level" on auto

  echo -e "\e[7mUSB autosuspend time\e[0m"
  newoutf "/sys/bus/usb/devices/*/power/autosuspend" 0 1

  echo -e "\e[7mPCI-E ASPM\e[0m"
  newoutf "/sys/module/pcie_aspm/parameters/policy" "default [performance] powersave powersupersave " "default performance powersave [powersupersave] "

  echo -e "\e[7mKernel VM parameters\e[0m"
  newoutf "/proc/sys/vm/laptop_mode" 0  5
  newoutf "/proc/sys/vm/dirty_ratio" 20 25
  newoutf "/proc/sys/vm/dirty_background_ratio" 5 15
  newoutf "/proc/sys/vm/dirty_writeback_centisecs" 500 3000
  newoutf "/proc/sys/vm/dirty_expire_centisecs" 1000 10000

  echo -e "\e[7mSATA ALPM\e[0m"
  newoutf "/sys/class/scsi_host/host*/link_power_management_policy" max_performance min_power

  echo -e "\e[7mSound card powersave\e[0m"
  newoutf "/sys/module/snd_hda_intel/parameters/power_save" 0 1
  newoutf "/sys/module/snd_hda_intel/parameters/power_save_controller" N Y

  case $status in
    ac)
      okValue="off"
      badValue="on"
    ;;
    battery)
      okValue="on"
      badValue="off"
    ;;
    *)
      okValue=-whoknows
      badValue=-whoknows
    ;;
  esac

  echo -e "\e[7mWireless powersave\e[0m"
  value=`iw dev wlp2s0 get power_save | awk '{print $3}'`
  case ${value} in
  ${okValue})
      echo -e "wlp2s0 :" "\e[7;32m${value}\e[0m"
  ;;
  ${badValue})
      echo -e "wlp2s0 :" "\e[7;31m${value}\e[0m"
  ;;
  *)
      echo -e "wlp2s0 :" "\e[7;34m${value}\e[0m"
  ;;
  esac

  echo -e "Current status: " ${status}

  exit 0
fi

if [ -t 0 ]; then #not interactive (does not work?)
  echo " Output is redirected to /var/log/xps_power"
fi

exec >> /var/log/xps_power
exec 2>&1

echo `date +%d/%m/%Y_%H:%M:%S` "  Running xps_power script"

if [ -z "$1" ]; then
  echo `date +%d/%m/%Y_%H:%M:%S` "  ERROR: No arguments supplied."
  echo "                      Please specify 'ac', 'battery', 'auto' or 'status'."
  exit 2
fi

if [ "$1" == "auto" ]; then
  input="$status"
else
  input="$1"
fi
echo "                      Input: '$input'"

case "$input" in

  ac) # Return to default on AC power
    echo `date +%d/%m/%Y_%H:%M:%S` "  AC mode selected"

    #Set limits for maximum and minimum frequency
    echo 25  > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 0   > /sys/devices/system/cpu/intel_pstate/no_turbo
    for i in /sys/devices/system/cpu/cpu?/cpufreq/energy_performance_preference ; do echo balance_performance > ${i} ; done

    # Device and disk runtime-PM and USB power control (one can do that on {usb,pci,i2c} only if needed)
    #The first one might conflict with nvidia devices starting, so we exclude the PCI devices
#     for i in /sys/bus/*/devices/*/power/control; do echo auto > ${i} ; done
    for i in /sys/bus/!(pci*)/devices/*/power/control; do echo on > ${i} ; done
    for i in /sys/bus/*/devices/*/ata*/power/control; do echo on > ${i} ; done
    for i in /sys/block/*/device/power/control; do echo on > ${i} ; done

    # USB autosuspend
    for i in /sys/bus/usb/devices/*/power/autosuspend; do echo 0 > $i; done
    for i in /sys/bus/usb/devices/*/power/level; do echo on > $i; done

    # PCI-E ASPM
    echo performance > /sys/module/pcie_aspm/parameters/policy

    # Kernel write mode
    echo 0    > /proc/sys/vm/laptop_mode
    echo 20   > /proc/sys/vm/dirty_ratio
    echo 5    > /proc/sys/vm/dirty_background_ratio
    echo 500  > /proc/sys/vm/dirty_writeback_centisecs
    echo 1000 > /proc/sys/vm/dirty_expire_centisecs

    # SATA ALPM
    for i in /sys/class/scsi_host/host*/link_power_management_policy; do echo max_performance > ${i} ; done

    # Sound card powersave
    echo 0 > /sys/module/snd_hda_intel/parameters/power_save
    echo N > /sys/module/snd_hda_intel/parameters/power_save_controller

    # Wifi powersave
    iw dev wlp2s0 set power_save off &> /dev/null

    #Intel GPU speed
    sudo /usr/bin/intel_gpu_frequency -m

    echo `date +%d/%m/%Y_%H:%M:%S` "  AC mode applied"
  ;;

  coolac) # Enable power saving settings on battery
    echo `date +%d/%m/%Y_%H:%M:%S` "  Battery mode selected"

    #Set limits for maximum and minimum frequency
    echo 25  > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    echo 100  > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 0   > /sys/devices/system/cpu/intel_pstate/no_turbo
    for i in /sys/devices/system/cpu/cpu?/cpufreq/energy_performance_preference ; do echo balance_performance > ${i} ; done

    # Device and disk runtime-PM and USB power control (one can do that on {usb,pci,i2c} only if needed)
    #The first one might conflict with nvidia devices starting, so we exclude the PCI devices
#     for i in /sys/bus/*/devices/*/power/control; do echo auto > ${i} ; done
    for i in /sys/bus/!(pci*)/devices/*/power/control; do echo on > ${i} ; done
    for i in /sys/bus/*/devices/*/ata*/power/control; do echo on > ${i} ; done
    for i in /sys/block/*/device/power/control; do echo on > ${i} ; done

    # USB autosuspend
    for i in /sys/bus/usb/devices/*/power/autosuspend; do echo 0 > $i; done
    for i in /sys/bus/usb/devices/*/power/level; do echo on > $i; done

    # PCI-E ASPM
    echo powersave > /sys/module/pcie_aspm/parameters/policy

    # Kernel write mode
    echo 0    > /proc/sys/vm/laptop_mode
    echo 20   > /proc/sys/vm/dirty_ratio
    echo 5    > /proc/sys/vm/dirty_background_ratio
    echo 500  > /proc/sys/vm/dirty_writeback_centisecs
    echo 1000 > /proc/sys/vm/dirty_expire_centisecs

    # SATA ALPM
    for i in /sys/class/scsi_host/host*/link_power_management_policy; do echo min_power > ${i} ; done

    # Sound card powersave
    echo 0 > /sys/module/snd_hda_intel/parameters/power_save
    echo N > /sys/module/snd_hda_intel/parameters/power_save_controller

    # Wifi powersave
    iw dev wlp2s0 set power_save off &> /dev/null

    #Intel GPU speed
    sudo /usr/bin/intel_gpu_frequency -m

    echo `date +%d/%m/%Y_%H:%M:%S` "  Battery mode applied"
  ;;

  battery) # Enable power saving settings on battery
    echo `date +%d/%m/%Y_%H:%M:%S` "  Battery mode selected"

    #Set limits for maximum and minimum frequency
    echo 5  > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    echo 80  > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 1   > /sys/devices/system/cpu/intel_pstate/no_turbo
    for i in /sys/devices/system/cpu/cpu?/cpufreq/energy_performance_preference ; do echo balance_power > ${i} ; done

    # Device and disk runtime-PM and USB power control (one can do that on {usb,pci,i2c} only if needed)
    #The first one might conflict with nvidia devices starting, so we exclude the PCI devices
#     for i in /sys/bus/*/devices/*/power/control; do echo auto > ${i} ; done
    for i in /sys/bus/!(pci*)/devices/*/power/control; do echo auto > ${i} ; done
    for i in /sys/bus/*/devices/*/ata*/power/control; do echo auto > ${i} ; done
    for i in /sys/block/*/device/power/control; do echo auto > ${i} ; done

    # USB autosuspend
    for i in /sys/bus/usb/devices/*/power/autosuspend; do echo 1 > $i; done
    for i in /sys/bus/usb/devices/*/power/level; do echo auto > $i; done

    # PCI-E ASPM
    echo powersupersave > /sys/module/pcie_aspm/parameters/policy

    # Kernel write mode
    echo 5     > /proc/sys/vm/laptop_mode
    echo 25    > /proc/sys/vm/dirty_ratio
    echo 15    > /proc/sys/vm/dirty_background_ratio
    echo 3000  > /proc/sys/vm/dirty_writeback_centisecs
    echo 10000 > /proc/sys/vm/dirty_expire_centisecs

    # SATA ALPM
    for i in /sys/class/scsi_host/host*/link_power_management_policy; do echo min_power > ${i} ; done

    # Sound card powersave
    echo 1 > /sys/module/snd_hda_intel/parameters/power_save
    echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller

    # Wifi powersave
    iw dev wlp2s0 set power_save on &> /dev/null

    #Intel GPU speed
    sudo /usr/bin/intel_gpu_frequency -e

    echo `date +%d/%m/%Y_%H:%M:%S` "  Battery mode applied"
  ;;

  *) # Anything else
    echo `date +%d/%m/%Y_%H:%M:%S` "  ERROR: Invalid script input or unknown AC/battery status"
    exit 3
  ;;

esac

echo `date +%d/%m/%Y_%H:%M:%S` "  Exiting xps_power script"

exit 0
}
