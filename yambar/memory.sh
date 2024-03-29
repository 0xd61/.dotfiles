#!/usr/bin/env bash

# cpu.sh - measures CPU usage at a configurable sample interval
#
# Usage: cpu.sh INTERVAL_IN_SECONDS
#
# This script will emit the following tags on stdout (N is the number
# of logical CPUs):
#
#  Name   Type
#  --------------------
#  cpu    range 0-100
#  cpu0   range 0-100
#  cpu1   range 0-100
#  ...
#  cpuN-1 range 0-100
#
# I.e. ‘cpu’ is the average (or aggregated) CPU usage, while cpuX is a
# specific CPU’s usage.
#
# Example configuration (update every second):
#
#  - script:
#      path: /path/to/cpu.sh
#      args: [1]
#      content: {string: {text: "{cpu}%"}}
#

interval=${1}

case ${interval} in
    ''|*[!0-9]*)
        echo "interval must be an integer"
        exit 1
        ;;
    *)
        ;;
esac

# Arrays of ‘previous’ idle and total stats, needed to calculate the
# difference between each sample.
prev_average_idle=0
prev_average_total=0

while true; do
    IFS=$'\n' readarray -t all_meminfo_stats < <(cat /proc/stat)

    usage=()           # CPU usage in percent, 0 <= x <= 100

    average_idle=0  # All CPUs idle time since boot
    average_total=0 # All CPUs total time since boot

    for i in $(seq 0 $((cpu_count - 1))); do
        # Split this CPUs stats into an array
        stats=($(echo "${all_cpu_stats[$((i + 1))]}"))

        # man procfs(5)
        user=${stats[1]}
        nice=${stats[2]}
        system=${stats[3]}
        idle=${stats[4]}
        iowait=${stats[5]}
        irq=${stats[6]}
        softirq=${stats[7]}
        steal=${stats[8]}
        guest=${stats[9]}
        guestnice=${stats[10]}

        # Guest time already accounted for in user
        user=$((user - guest))
        nice=$((nice - guestnice))

        idle=$((idle + iowait))

        total=$((user + nice + system + irq + softirq + idle + steal + guest + guestnice))

        average_idle=$((average_idle + idle))
        average_total=$((average_total + total))

        # Diff since last sample
        diff_idle=$((idle - prev_idle[i]))
        diff_total=$((total - prev_total[i]))

        usage[i]=$((100 * (diff_total - diff_idle) / diff_total))

        prev_idle[i]=${idle}
        prev_total[i]=${total}
    done

    diff_average_idle=$((average_idle - prev_average_idle))
    diff_average_total=$((average_total - prev_average_total))

    average_usage=$((100 * (diff_average_total - diff_average_idle) / diff_average_total))

    prev_average_idle=${average_idle}
    prev_average_total=${average_total}

    echo "cpu|range:0-100|${average_usage}"
    for i in $(seq 0 $((cpu_count - 1))); do
        echo "cpu${i}|range:0-100|${usage[i]}"
    done

    echo ""
    sleep "${interval}"
done

