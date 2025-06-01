#!/bin/bash

if [ ! $1 ]; then echo "Usage: startchroot CHROOT"; exit; fi

CHROOT=$1
if [ ! -d /mnt/virt/chroot/$1 ]; then
	echo "Couldn't find chroot"
	exit 1
fi

sudo rm /mnt/virt/chroot/$CHROOT/root/.Xauthority
sudo cp /home/$USER/.Xauthority /mnt/virt/chroot/$CHROOT/root/

# verification du montage
if [[ $(mount | grep $CHROOT) = "" ]]; then
    xhost +si:localuser:root
    sudo mount -o bind /dev /mnt/virt/chroot/$CHROOT/dev
    sudo mount -o bind /dev /mnt/virt/chroot/$CHROOT/dev/pts
    sudo mount -o bind /proc /mnt/virt/chroot/$CHROOT/proc
    sudo mount -o bind /sys /mnt/virt/chroot/$CHROOT/sys
    sudo mount -o bind /run /mnt/virt/chroot/$CHROOT/run
fi

sudo chroot /mnt/virt/chroot/$CHROOT/ /bin/bash

echo "Cleaning up..."
sudo umount /mnt/virt/chroot/$CHROOT/dev/pts
sudo umount /mnt/virt/chroot/$CHROOT/dev
sudo umount /mnt/virt/chroot/$CHROOT/proc
sudo umount /mnt/virt/chroot/$CHROOT/sys
sudo umount /mnt/virt/chroot/$CHROOT/run
