#!/usr/bin/env bash

NETWORK_IF="wlp2s0"
BRIDGE="vmbr0"
TAP="tap0"

if [ "$1" = "up" ]; then
    sudo ip tuntap add dev ${TAP} mode tap group kvm
    sudo ip link set dev ${TAP} up promisc on
    sudo ip addr add 0.0.0.0 dev ${TAP}

    sudo ip link add ${BRIDGE} type bridge
    sudo ip link set ${BRIDGE} up
    sudo ip link set ${TAP} master ${BRIDGE}
    echo 0 > sudo tee /sys/class/net/${BRIDGE}/bridge/stp_state
    sudo ip addr add 10.0.1.1/24 dev ${BRIDGE}

    sudo sysctl net.ipv4.conf.${TAP}.proxy_arp=1
    sudo sysctl net.ipv4.conf.${NETWORK_IF}.proxy_arp=1
    sudo sysctl net.ipv4.ip_forward=1

    sudo iptables -t nat -A POSTROUTING -o ${NETWORK_IF} -j MASQUERADE
    sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i ${BRIDGE} -o ${NETWORK_IF} -j ACCEPT
elif [ "$1" = "down" ]; then
    sudo ip link del ${BRIDGE}
    sudo ip link del ${TAP}
else
    echo usage: kvm-network.sh [command]
    echo commands:
    echo -e "\tup - start NAT bridge"
    echo -e "\tdown - stop NAT bridge"
fi

# -usbdevice tablet
# -nic tap,ifname=tap0,script=no,downscript=no
