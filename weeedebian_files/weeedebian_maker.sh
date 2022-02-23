#!/bin/bash
HOSTNAME=""
ROOTPASSWD=""
USERNAME=""
USERPASSWD=""

while [[ $HOSTNAME == "" ]]; do
    echo "Insert hostname: "
    read HOSTNAME
done

while [[ $ROOTPASSWD == "" ]]; do
    echo "Insert root password: "
    read ROOTPASSWD
    ROOTPASSWD=$(openssl passwd -6 "$ROOTPASSWD")
done

while [[ $USERNAME == "" ]]; do
    echo "Insert username: "
    read USERNAME
done

while [[ $USERPASSWD == "" ]]; do
    echo "Insert passwd: "
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

mkdir -p weeedebian

sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    buster \
    weeedebian/chroot \
    http://ftp.it.debian.org/debian/

cat << EOF | sudo chroot weeedebian/chroot
echo "weeedebian" > /etc/hostname
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
git pull https://github.com/WEEE-Open/falce.git
mv falce/weeedebian_files /weeedebian_files
/weeedebian_files/martello.sh
useradd -m $USERNAME
sed -i 's#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#' /etc/shadow
sed -i 's#$USERNAME:.*#$USERNAME:$USERPASSWD:18214:0:99999:7:::#' /etc/shadow
EOF

mkdir -p weeedebian/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

sudo mksquashfs \
    weeedebian/chroot \
    weeedebian/staging/live/filesystem.squashfs \
    -e boot

cp weeedebian/chroot/boot/vmlinuz-* \
    weeedebian/staging/live/vmlinuz && \
cp weeedebian/chroot/boot/initrd.img-* \
    weeedebian/staging/live/initrd

cat <<'EOF' >weeedebian/staging/isolinux/isolinux.cfg
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

cat <<'EOF' >weeedebian/staging/boot/grub/grub.cfg
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

cat <<'EOF' >weeedebian/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

touch weeedebian/staging/DEBIAN_CUSTOM

cp /usr/lib/ISOLINUX/isolinux.bin "weeedebian/staging/isolinux/"
cp /usr/lib/syslinux/modules/bios/* "weeedebian/staging/isolinux/"
cp -r /usr/lib/grub/x86_64-efi/* "weeedebian/staging/boot/grub/x86_64-efi/"

grub-mkstandalone \
    --format=x86_64-efi \
    --output=weeedebian/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=weeedebian/tmp/grub-standalone.cfg"

(cd weeedebian/staging/EFI/boot && \
dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
mkfs.vfat efiboot.img && \
mmd -i efiboot.img efi efi/boot && \
mcopy -vi efiboot.img weeedebian/tmp/bootx64.efi ::efi/boot/
)

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "weeedebian/debian-custom.iso" \
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
    -append_partition 2 0xef weeedebian/staging/EFI/boot/efiboot.img \
    "weeedebian/staging"

while true; do
    read -p "Do you want to remove all build dependencies? y/N" yn
    case $yn in
        [Yy]* ) sh ./weeedebian_remove_dep.sh; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

