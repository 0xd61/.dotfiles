#!/usr/bin/env bash

# temperature.sh - show cpu and system temperature at a configurable sample interval
#
# Usage: temperature.sh INTERVAL_IN_SECONDS
#
# This script will emit the following tags on stdout:
#
#  Name   Type
#  --------------------
#  cpu    string
#  system string
#
# Example configuration (update every second):
#
#  - script:
#      path: /path/to/temperature.sh
#      args: [1]
#      content: {string: {text: "{cpu}"}}

interval=${1}

case ${interval} in
    ''|*[!0-9]*)
        echo "interval must be an integer"
        exit 1
        ;;
    *)
        ;;
esac

while true; do
    cpu=$(sensors | awk '/^CPUTIN/ { print $2 }')
    system=$(sensors | awk '/^SYSTIN/ { print $2 }')

    echo "cpu|string|${cpu}"
    echo "system|string|${system}"

    echo ""
    sleep "${interval}"
done

