#!/bin/sh

# Alternatively test this: https://github.com/stockmind/dell-xps-9560-ubuntu-respin/issues/60#issue-481896914

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: not running with root permissions."
  echo "Please run as root!"
  exit 1
fi

if ! lsmod | grep -q acpi_call; then
    echo "Error: acpi_call module not loaded"
    exit
fi

acpi_call () {
    echo "$*" > /proc/acpi/call
    cat /proc/acpi/call
}

if [ $# -ne 2 ]; then
    # NOTE(dgl): @hack we only call the _ON or _OFF method and do not change the power states.
    # This way the card thinks it is on, but actually is turned off. With the powerstates we card
    # did not want to turn off.
    case "$1" in
    off)
        echo _DSM $(acpi_call "\_SB.PCI0.PEG0.PEGP._DSM" \
                              "{0xF8,0xD8,0x86,0xA4,0xDA,0x0B,0x1B,0x47," \
                              "0xA7,0x2B,0x60,0x42,0xA6,0xB5,0xBE,0xE0}" \
                              "0x100 0x1A {0x1,0x0,0x0,0x3}" | tr -d '\0')
        # ok to turn off: Buffer {0x59 0x0 0x0 0x11}
        # is already off: Buffer {0x41 0x0 0x0 0x11}
        echo Make sure the GPU is not used. It might freeze the screen.
        read -p "Confirm if you want to disble the GPU [yN] " answer
        if [ "$answer" != "${answer#[Yy]}" ] ;then
            #echo _PS3 $(acpi_call "\_SB.PCI0.PEG0.PEGP._PS3" | tr -d '\0')
            echo _OFF $(acpi_call "\_SB.PCI0.PEG0.PEGP._OFF" | tr -d '\0')
        fi
    ;;
    on)
        #echo _PS0 $(acpi_call "\_SB.PCI0.PEG0.PEGP._PS0" | tr -d '\0')
        echo _ON $(acpi_call "\_SB.PCI0.PEG0.PEGP._ON" | tr -d '\0')
    ;;
    *)
        echo "Usage: $0 [on|off]"
    esac
fi


PSC=$(acpi_call "\_SB.PCI0.PEG0.PEGP._PSC" | tr -d '\0')
#echo _PSC ${PSC}
case "$PSC" in
0x0)
    PSC="on"
;;
0x3)
    PSC="off"
;;
esac
echo "Dell XPS 9560 Optimus appears to be ${PSC}."
