#!/bin/bash
#http://www.linux-kvm.org/page/Simple_shell_script_to_manage_your_virtual_machine_with_bridged_networking

# TODO(dgl):
# - auto create run dir
# - merge kvm-network.sh

######################
## Default settings ##
######################

## Directory and files
if ! [ -d $2 ]
then
	DIR_BASE=`pwd $`
else
	DIR_BASE=$2
fi
FILE_CONF=${DIR_BASE}/conf

### run directory will be auto-created with following files
DIR_RUN=${DIR_BASE}/run
FILE_MONITOR=${DIR_RUN}/monitor
FILE_PID=${DIR_RUN}/pid
FILE_OUT=${DIR_RUN}/out

GUEST_ID=0
GUEST_MEMORY=1024
GUEST_IP=192.168.1.97
HOST_INTERFACE=wlp2s0
BRIDGE=vmbr0
BRIDGE_IP=10.0.1.1/24

### generated variables
TAP=tap0${GUEST_ID}
#MAC_ADDR=00:16:3e:${GUEST_ID}:00:01
#VNC_DISPLAY=3${GUEST_ID}00
#VNC_PORT=`expr ${VNC_DISPLAY} + 5900`

### options for kvm
#OPT_BOOT="-boot c"
OPT_BOOT=""

#OPT_CDROM="-cdrom /media/cdrom"
OPT_CDROM=""

#OPT_STD_VGA="-std-vga"
OPT_STD_VGA=""

#OPT_USBDEVICE="-usbdevice tablet"
OPT_USBDEVICE="-usbdevice tablet"

#OPT_NO_ACPI="-no-acpi"
OPT_NO_ACPI=""

#OPT_CPU="-cpu qemu64"
OPT_CPU=""

OPT_NIC="-nic tap,ifname=${TAP},script=no,downscript=no"

#OPT_DRIVE="-drive <drive>"
OPT_DRIVE=""

#OPT_HDB="-hdb <hdb>"
OPT_HDB=""

#OPT_VNC="-vnc :${VNC_DISPLAY}"
OPT_VNC=""

#OPT_HDA="-hda <hda>"
OPT_HDA=""

#OPT_SMP="-smp 4"
OPT_SMP=""

OPT_KBD_LAYOUT="de"

OPT_SERIAL=""

OPT_OTHER=""

if [ -f ${FILE_CONF} ]
then
        . ${FILE_CONF}
fi

__check_root() {
	if [ "$EUID" -ne 0 ]
  	then echo "Please run as root"
  	exit
	fi
}

### wireless network
start_net() {
		__check_root()
    echo "start network adapter ${TAP_NAME}"
		ip tuntap add dev ${TAP} mode tap group kvm
    ip link set dev ${TAP} up promisc on
    ip addr add 0.0.0.0 dev ${TAP}
    ip link set ${TAP} master ${BRIDGE}

    sysctl net.ipv4.conf.${TAP}.proxy_arp=1
    echo "network adapter ${TAP} is started with as ip ${GUEST_IP}"
}
stop_net() {
		__check_root()
    echo "stop network adapter ${TAP}"
		ip link del ${TAP}
}
start_bridge() {
		__check_root()
		ip link add ${BRIDGE} type bridge
    ip link set ${BRIDGE} up
    echo 0 > tee /sys/class/net/${BRIDGE}/bridge/stp_state
    ip addr add ${BRIDGE_IP} dev ${BRIDGE}

    sysctl net.ipv4.conf.${HOST_INTERFACE}.proxy_arp=1
    sysctl net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o ${HOST_INTERFACE} -j MASQUERADE
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ${BRIDGE} -o ${HOST_INTERFACE} -j ACCEPT

    echo "bridge ${BRIDGE} started"
}
stop_bridge() {
		__check_root()
		echo "stop network bridge ${BRIDGE}"
		ip link del ${BRIDGE}
}

check_net_status() {
        NET_STATUS=`ifconfig | grep ${TAP}`
        if test "${NET_STATUS}" = ""
        then
                echo "network adapter ${TAP} has not been started"
        else
                echo "network adapter ${TAP} has been started"
        fi
}

## virtual machine
start_vm_sliently() {
        echo "start virtual machine"

        if ! [ -d ${DIR_RUN} ]
        then
                mkdir ${DIR_RUN}
        fi

        kvm \
                ${OPT_HDA} \
                ${OPT_HDB} \
                ${OPT_DRIVE} \
                ${OPT_CPU} \
                ${OPT_SMP} \
                ${OPT_CDROM} \
                -m ${GUEST_MEMORY} \
                ${OPT_BOOT} \
                ${OPT_USBDEVICE} \
                ${OPT_SERIAL} \
                ${OPT_NIC} \
                -k ${OPT_KBD_LAYOUT} \
                ${OPT_STD_VGA} \
                -monitor unix:${FILE_MONITOR},server,nowait \
                -pidfile ${FILE_PID} \
                ${OPT_NO_ACPI} \
                ${OPT_VNC} \
                ${OPT_OTHER} &

        # check if the pid file created successfully
        if [ ! -f ${FILE_PID} ]
        then
                sleep 1
        fi

        if [ ! -f ${FILE_PID} ]
        then
                return 1
        fi

        # check if the process started successfully
        if [ ! -d /proc/`cat ${FILE_PID}` ]
        then
                return 1
        fi
}
start_vm() {
        start_vm_sliently

        # if start_vm_sliently return -1
        if test $? -eq -1
        then
                echo "startup failed. check ${FILE_OUT}"
                exit 1
        else
                echo "startup successfully"
         fi
}
send_cmd() {
        QEMU_MONITOR_COMMAND=$1
        echo "${QEMU_MONITOR_COMMAND}" | socat - UNIX-CONNECT:${FILE_MONITOR}
}
get_vm_pid_to() {
        ACTION_TO_DO=$1
        # check if pid file there
        if [ ! -f ${FILE_PID} ]
        then
                echo "${FILE_PID} not found, can not ${ACTION_TO_DO}"
                exit 1
        fi

        VM_PID=`cat ${FILE_PID}`
}
check_vm_status() {
        get_vm_pid_to "check vm status"
        if [ -d /proc/${VM_PID} ]
        then
                echo "vm is running at process id ${VM_PID}"
        else
                echo "vm is not running"
        fi
}
stop_vm() {
        echo "stop virtual machine"

        get_vm_pid_to "stop vm"
        # check if monitor file there
        if [ ! -e ${FILE_MONITOR} ]
        then
                echo "${FILE_MONITOR} not found, can not stop vm"
                exit 1
        fi
        # if the process is still running
        # send command quit to its monitor, and wait
        if [ -d /proc/${VM_PID} ]
        then
                send_cmd "quit"
        fi
        # check if the process is still running
        if [ -d /proc/${VM_PID} ]
        then
                sleep 1
        fi
        if [ ! -d /proc/${VM_PID} ]
        then
                # yes, done
                rm ${FILE_PID}
                rm ${FILE_MONITOR}
                echo "vm stopped successfully"
        else
                # no, something wrong there...
                echo "failed to stop vm"
                exit 1
        fi
}
kill_vm() {
        echo "kill virtual machine"

        get_vm_pid_to "kill vm"

        # if the process is still running, kill it
        if [ -d /proc/${VM_PID} ]
        then
                kill ${VM_PID}
        fi

        rm ${FILE_PID}
        rm ${FILE_MONITOR}
        echo "vm killed"
}
detect_module() {
. /lib/lsb/init-functions

# Figure out which module we need.
	if grep -q ^flags.*\\\<vmx\\\> /proc/cpuinfo
	then
		module=kvm_intel
	elif grep -q ^flags.*\\\<svm\\\> /proc/cpuinfo
	then
		module=kvm_amd
	else
		module=
	fi
}
start_kvm() {
	detect_module

	if [ -z "$module" ]
	then
		log_failure_msg "Your system does not have the CPU extensions required to use KVM. Not doing anything."
		exit 0
	fi
	if modprobe "$module"
	then
		log_success_msg "Loading kvm module $module"
	else
		log_failure_msg "Module $module failed to load"
		exit 1
	fi
}
stop_kvm() {
	detect_module

	if [ -z "$module" ]
	then
		exit 0
	fi
	if lsmod | grep -q "$module"
	then
		if rmmod "$module"
		then
			log_success_msg "Succesfully unloaded kvm module $module"
			rmmod kvm
		else
			log_failure_msg "Failed to remove $module"
			exit 1
		fi
	else
		log_failure_msg "Module $module not loaded"
	fi
}
### Main switch
case "$1" in
init)
	DIR_BASE=`pwd $`
	read -p "Base Directory: [${DIR_BASE}] " input
	DIR_BASE=${input:-$DIR_BASE}
	mkdir -p $DIR_BASE
	touch ${DIR_BASE}/conf
	echo "#DIR_RUN=${DIR_BASE}/_run" >> ${DIR_BASE}/conf
	echo "#FILE_MONITOR=\${DIR_RUN}/monitor" >> ${DIR_BASE}/conf
	echo "#FILE_PID=\${DIR_RUN}/pid" >> ${DIR_BASE}/conf
	echo "#FILE_OUT=\${DIR_RUN}/out" >> ${DIR_BASE}/conf
	echo "#GUEST_ID=0" >> ${DIR_BASE}/conf
	echo "#GUEST_MEMORY=1024" >> ${DIR_BASE}/conf
	echo "#GUEST_IP=10.18.18.1\${GUEST_ID}" >> ${DIR_BASE}/conf
	echo "#HOST_IP=10.18.18.1/24" >> ${DIR_BASE}/conf
	echo "#HOST_INTERFACE=wlp2s0" >> ${DIR_BASE}/conf
	echo "#TAP=tap0\${GUEST_ID}" >> ${DIR_BASE}/conf
	echo "#BRIDGE=vmbr0" >> ${DIR_BASE}/conf
	echo '#OPT_BOOT="-boot c"' >> ${DIR_BASE}/conf
	echo '#OPT_CDROM=""' >> ${DIR_BASE}/conf
	echo '#OPT_STD_VGA="-std-vga"' >> ${DIR_BASE}/conf
	echo '#OPT_USBDEVICE="-usbdevice tablet"' >> ${DIR_BASE}/conf
	echo '#OPT_NO_ACPI=""' >> ${DIR_BASE}/conf
	echo '#OPT_CPU="-cpu qemu64"' >> ${DIR_BASE}/conf
	echo '#OPT_NIC=""' >> ${DIR_BASE}/conf
	echo '#OPT_DRIVE=""' >> ${DIR_BASE}/conf
	echo '#OPT_HDB=""' >> ${DIR_BASE}/conf
	echo '#OPT_VNC=""' >> ${DIR_BASE}/conf
	echo '#OPT_HDA=""' >> ${DIR_BASE}/conf
	echo '#OPT_SMP="-smp 4"' >> ${DIR_BASE}/conf
	echo '#OPT_SERIAL=""' >> ${DIR_BASE}/conf
	echo '#OPT_OTHER=""' >> ${DIR_BASE}/conf
	;;
start-kvm)
	start_kvm
	;;
start-bridge)
  start_bridge
  ;;
start-net)
        start_net
        ;;

start-vm)
        start_vm
        ;;

start)
        sudo start_net
        start_vm
        ;;

status)
        check_net_status
        check_vm_status
        ;;

cad)
        send_cmd "sendkey ctrl-alt-delete"
        ;;

vnc)
        vncviewer localhost:${VNC_PORT} &
        ;;

rdesktop)
        rdesktop $2 $3 ${GUEST_IP} &
        ;;

ssh)
        ssh ${GUEST_IP}
        ;;

ping)
        ping ${GUEST_IP}
        ;;

halt)
        ssh root@${GUEST_IP} halt
        ;;

reset)
        send_cmd "system_reset"
        ;;

stop-vm)
        stop_vm
        ;;

stop-net)
        stop_net
        ;;
stop-bridge)
  			stop_bridge
  			;;
stop)
        stop_vm
        sudo stop_net
        ;;
stop-kvm)
	stop_kvm
	;;
kill)
        kill_vm
        sleep 1
        stop_net
        ;;

*)
	echo "KVM manager version 0.1, Samuel Bally"
	echo "usage: kvm-manager [options] [path]"
	echo ""
	echo "Standard options:"
	echo "You need to specify a action, available actions are:"
	echo "[init] creates default config file"
  echo "[start-bridge] start NAT bridge"
  echo "[start] start both"
  echo "[status] check the status of network and virtual machine"
  echo "[cad] ctrl-alt-delete"
  echo "[vnc] use vinagre to view the vnc of the guest"
  echo "[rdesktop] remote desktop to the guest"
  echo "[ssh] ssh to the guest"
  echo "[ping] ping guest"
  echo "[halt] ssh to the guest and halt the guest"
  echo "[reset] reset the virtual machine"
  echo "[stop-bridge] stop NAT bridge"
  echo "[stop] stop both"
  echo "[kill] kill the viritual machine and network"
	echo ""
	echo "Config file:"
	echo "create a conf file in your vm directory for change default settings"
	echo "conf varialbles:"
	echo "DIR_RUN"
	echo "FILE_MONITOR"
	echo "FILE_PID"
	echo "FILE_OUT"
	echo "GUEST_ID"
	echo "GUEST_MEMORY"
	echo "GUEST_IP"
	echo "HOST_IP"
	echo "HOST_INTERFACE"
	echo "OPT_BOOT"
	echo "OPT_CDROM"
	echo "OPT_STD_VGA"
	echo "OPT_USBDEVICE"
	echo "OPT_NO_ACPI"
	echo "OPT_CPU"
	echo "OPT_NIC"
	echo "OPT_DRIVE"
	echo "OPT_HDB"
	echo "OPT_VNC"
	echo "OPT_HDA"
	echo "OPT_SMP"
	echo "OPT_SERIAL"
	echo "OPT_OTHER"
        exit 1
        ;;

esac
exit
