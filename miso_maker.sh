#!/bin/bash

while [[ -z "$HOSTNAME" ]]; do
    echo -n "Hostname: "
    read HOSTNAME
done

while [[ -z "$ROOTPASSWD" ]]; do
    echo -n "Root password: "
    read ROOTPASSWD
    ROOTPASSWD=$(openssl passwd -6 "$ROOTPASSWD")
done

while [[ -z "$USERNAME" ]]; do
    echo -n "Username: "
    read USERNAME
done

while [[ -z "$USERPASSWD" ]]; do
    echo -n "$USERNAME password: "
    read USERPASSWD
    USERPASSWD=$(openssl passwd -6 "$USERPASSWD")
done


sudo apt install \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    debian-archive-keyring \
    isolinux \
    syslinux

# TODO: uncomment
# TODO: env var to choose 32 bit, 64 bit or both
# TODO: make a function

#mkdir -p /build/weeedebian32
#
#sudo debootstrap \
#    --arch=i386 \
#    --variant=minbase \
#    buster \
#    /build/weeedebian32 \
#    http://ftp.it.debian.org/debian/
#
#cat << EOF | sudo chroot /build/weeedebian32
#echo "${HOSTNAME}32" > /etc/hostname
#export DEBIAN_FRONTEND=noninteractive
#apt update && apt install -y --no-install-recommends \
#    linux-image-amd64 \
#    live-boot \
#    systemd-sysv \
#    network-manager net-tools wireless-tools wpagui \
#    curl openssh-client \
#    blackbox xorg xserver-xorg-core xserver-xorg xinit xterm \
#    nano git\
#    lightdm xfce4
#apt clean
#useradd -m $USERNAME
#sed -i 's#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#' /etc/shadow
#sed -i 's#$USERNAME:.*#$USERNAME:$USERPASSWD:18214:0:99999:7:::#' /etc/shadow
#/weeedebian_files/martello.sh
#EOF

BUILD_DIR=/build/weeedebian64

mkdir -p $BUILD_DIR

sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    buster \
    $BUILD_DIR/chroot \
    http://ftp.it.debian.org/debian/

# TODO: make /weeedebian_files/martello.sh a configurable path
# TODO: can we move everything except apt install to martello? Or even that?
cat << EOF | sudo chroot $BUILD_DIR/chroot
echo "${HOSTNAME}32" > /etc/hostname
export DEBIAN_FRONTEND=noninteractive
apt update && apt install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv \
    network-manager net-tools wireless-tools wpagui \
    curl openssh-client \
    blackbox xorg xserver-xorg-core xserver-xorg xinit xterm \
    nano git\
    lightdm xfce4
apt clean
useradd -m $USERNAME
sed -i 's#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#' /etc/shadow
sed -i 's#$USERNAME:.*#$USERNAME:$USERPASSWD:18214:0:99999:7:::#' /etc/shadow
/weeedebian_files/martello.sh
EOF

mkdir -p $BUILD_DIR/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

sudo mksquashfs \
    $BUILD_DIR/chroot \
    $BUILD_DIR/staging/live/filesystem.squashfs \
    -e boot

cp $BUILD_DIR/chroot/boot/vmlinuz-* \
    $BUILD_DIR/staging/live/vmlinuz && \
cp $BUILD_DIR/chroot/boot/initrd.img-* \
    $BUILD_DIR/staging/live/initrd

cat <<'EOF' >$BUILD_DIR/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF

cat <<'EOF' >$BUILD_DIR/staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "WEEEDebian Live [EFI/GRUB]" {
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd
}

menuentry "WEEEDebian Live [EFI/GRUB] (nomodeset)" {
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF

cat <<'EOF' >$BUILD_DIR/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

touch $BUILD_DIR/staging/DEBIAN_CUSTOM

cp /usr/lib/ISOLINUX/isolinux.bin "$BUILD_DIR/staging/isolinux/"
cp /usr/lib/syslinux/modules/bios/* "$BUILD_DIR/staging/isolinux/"
cp -r /usr/lib/grub/x86_64-efi/* "$BUILD_DIR/staging/boot/grub/x86_64-efi/"

grub-mkstandalone \
    --format=x86_64-efi \
    --output=$BUILD_DIR/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$BUILD_DIR/tmp/grub-standalone.cfg"

(cd $BUILD_DIR/staging/EFI/boot && \
dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
mkfs.vfat efiboot.img && \
mmd -i efiboot.img efi efi/boot && \
mcopy -vi efiboot.img $BUILD_DIR/tmp/bootx64.efi ::efi/boot/
)

# TODO: -o with customized file name
xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "$BUILD_DIR/debian-custom.iso" \
    -full-iso9660-filenames \
    -volid "WEEEDEBIAN" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef $BUILD_DIR/staging/EFI/boot/efiboot.img \
    "$BUILD_DIR/staging"

# TODO: add a way to answer N automatically from the container (use an env var?)
while true; do
    read -p "Do you want to remove all build dependencies? [y/n]" yn
    case $yn in
        [Yy]* ) sh /weeedebian_files/weeedebian_remove_dep.sh; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

