#!/bin/bash

ORANGE='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RESET_COLOR='\033[0m'

# check if argument and if argument is valid
if [[ -z $1 ]]
then
  ARCH='64'
elif [ $1 != '64' ] || [ $1 != '32']
then
  echo -e "${RED}Wrong arguments. Please insert only 32 or 64 for architecture selection.${RESET_COLOR}"
  exit
else
  ARCH=$1
fi

# This thing is necessary for the prompts
HOSTNAME=""
ROOTPASSWD=""
USERNAME=""
USERPASSWD=""

# Prompts
while [[ $HOSTNAME == "" ]]; do
  read -p "Hostname: " HOSTNAME
done

while [[ $ROOTPASSWD == "" ]]; do
  read -sp "Root password: " ROOTPASSWD
  echo
  ROOTPASSWD=$(openssl passwd -6 "$ROOTPASSWD")
done

while [[ $USERNAME == "" ]]; do
  read -p "Username: " USERNAME
done

while [[ $USERPASSWD == "" ]]; do
  read -sp "$USERNAME password: " USERPASSWD
  echo
  USERPASSWD=$(openssl passwd -6 "$USERPASSWD")
done


# build the 32-bit chroot
function build_chroot_32 {
  BUILD_DIR='build/weeedebian32'

  mkdir -p $BUILD_DIR

  sudo debootstrap \
    --arch=i386 \
    --variant=minbase \
    buster \
    $BUILD_DIR/chroot \
    http://ftp.it.debian.org/debian/

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
  update-ca-certificates
  git clone https://github.com/WEEE-Open/falce.git
  mv falce/weeedebian_files /weeedebian_files
  rm -r falce
  sh /weeedebian_files/martello.sh
  rm -r /weeedebian_files
  echo "[SeatDefaults]" >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
  echo "autologin-user=<nome user>" >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
  echo "autologin-user-timeout=0"  >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
EOF
}

function build_chroot_64 {
  BUILD_DIR="build/weeedebian64"

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
  echo '${HOSTNAME}64' > /etc/hostname
  export DEBIAN_FRONTEND=noninteractive
  apt-get update && apt-get install -y \
    linux-image-amd64 \
    live-boot \
    systemd-sysv \
    network-manager net-tools wireless-tools wpagui \
    curl openssh-client apt-transport-https ca-certificates\
    xorg xserver-xorg-core xserver-xorg xinit '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev \
    libxkbcommon-dev libxkbcommon-x11-dev\
    nano git sudo firefox-esr\
    lightdm xfce4 xfce4-terminal xfce4-whiskermenu-plugin \
    rsync
  dpkg --configure -a
  apt-get clean
  useradd -m $USERNAME
  sed -i 's#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#' /etc/shadow
  sed -i 's#$USERNAME:.*#$USERNAME:$USERPASSWD:18214:0:99999:7:::#' /etc/shadow
  update-ca-certificates
  git clone https://github.com/WEEE-Open/falce.git
  mv falce/weeedebian_files /weeedebian_files
  rm -r falce
  /weeedebian_files/martello.sh $BUILD_DIR
  rm -r /weeedebian_files
  echo "[SeatDefaults]" >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
  echo 'autologin-user=$USERNAME' >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
  echo "autologin-user-timeout=0"  >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf
  sudo ln -s /usr/lib/x86_64-linux-gnu/libxcb-util.so.0 /usr/lib/x86_64-linux-gnu/libxcb-util.so.1
  cp -r /home/$USERNAME/.config/xfce4/ /home/$USERNAME/xfce4-pre-config/
EOF
}

# Install build dependencies
echo -e "${ORANGE}Installing build dependencies ...${BLUE}"
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

# Build chroot
if [[ $ARCH == '64' ]]
then
  echo -e "${ORANGE}Building chroot for 64-bit${RESET_COLOR}${BLUE}"
  build_chroot_64
else
  echo -e "${ORANGE}Building chroot for 32-bit${RESET_COLOR}${BLUE}"
  build_chroot_32
fi

# Create directory tree
mkdir -p $BUILD_DIR/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

# Squash filesystem
echo -e "${ORANGE}Squashing filesystem ...${BLUE}"
sudo mksquashfs \
    $BUILD_DIR/chroot \
    $BUILD_DIR/staging/live/filesystem.squashfs \
    -e boot

cp $BUILD_DIR/chroot/boot/vmlinuz-* \
    $BUILD_DIR/staging/live/vmlinuz && \
cp $BUILD_DIR/chroot/boot/initrd.img-* \
    $BUILD_DIR/staging/live/initrd

echo -e "${ORANGE}Building bootloader ...${BLUE}"
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
echo -e "${ORANGE}Building final ISO ...${BLUE}"
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
    echo -e "${RESET_COLOR}"
    read -p "Do you want to remove all build dependencies? [y/n]" yn
    case $yn in
        [Yy]* ) sh /weeedebian_files/weeedebian_remove_dep.sh; break;;
        [Nn]* ) echo -e "${GREEN}Everything done!${RESET_COLOR}"; exit;;
        * ) echo "Please answer y or n.";;
    esac
done

