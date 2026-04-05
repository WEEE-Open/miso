#!/bin/bash

#set -x # Logs
set -e # exit at any error

. .env
echo "MISO v$VERSION"

# These are not in the .env because they can't just be changed and might require some changes in miso.sh or in the chroot scripts
MISO_VARIANT="bookworm"
IMG_SIZE=10G

if [[ -z "$MISO_ARCH" ]]; then # '32' or 'i386' for 32bit, everything else is 64
    if [[ -z "$3" ]]; then
        echo "Set the architecture as the first parameter or via MISO_ARCH"
        exit 1
    else
        MISO_ARCH="$3"
    fi
fi

# These cannot be moved to the chroot, read doesn't work thru all those levels
while [[ -z "$MISO_HOSTNAME" ]]; do
    # read -p does not work from docker for some reason
    echo -n "Hostname: "
    read MISO_HOSTNAME
done

while [[ -z "$MISO_ROOTPASSWD" ]]; do
    echo -n "Root password: "
    # read -s doesn't work from docker
    stty -echo
    read MISO_ROOTPASSWD
    stty echo
done

while [[ -z "$MISO_USERNAME" ]]; do
    echo -n "Username: "
    read MISO_USERNAME
done

while [[ -z $MISO_USERPASSWD ]]; do
    echo -n "$MISO_USERNAME password: "
    stty -echo
    read MISO_USERPASSWD
    stty echo
done

_ORANGE='\033[0;33m'
_RED='\033[0;31m'
_BLUE='\033[0;34m'
_GREEN='\033[0;32m'
_RESET_COLOR='\033[0m'

# Build chroot
if [[ $MISO_ARCH == '32' || $MISO_ARCH == 'i386' ]]; then
    echo -e "${_BLUE}Building chroot for 32 bit${_RESET_COLOR}"
    MISO_ARCH=i386
else
    echo -e "${_BLUE}Building chroot for 64 bit${_RESET_COLOR}"
    MISO_ARCH=amd64
fi

if [[ "$MISO_ARCH" == "i386" ]]; then
    # There's also 686-pae
    LINUX_IMAGE_ARCH="686"
else
    LINUX_IMAGE_ARCH=$MISO_ARCH
fi

if [[ $MISO_PART_TABLE =~ ^(dos|mbr)$ ]]; then
    PART_TABLE="mbr"
    GRUB_PACKAGE=grub-pc
    GRUB_TARGET="i386-pc"
else
    PART_TABLE="gpt"
    if [[ "$MISO_ARCH" == "i386" ]]; then
        GRUB_TARGET="i386-efi"
        GRUB_PACKAGE=grub-efi-i386
    else
        GRUB_TARGET="x86_64-efi"
        GRUB_PACKAGE=grub-efi-amd64
    fi

fi
mkdir -p $MISO_BUILD_DIR
mkdir -p $MISO_CHROOT_SCRIPTS_DIR

CHROOT_SCRIPTS_DIR=$(readlink -f "$MISO_CHROOT_SCRIPTS_DIR")
BUILD_DIR=$(readlink -f "$MISO_BUILD_DIR")
BUILD_DIR="$BUILD_DIR/$MISO_DISTRO_NAME-$MISO_ARCH-$PART_TABLE"
IMG_PATH="$BUILD_DIR.$MISO_OUTPUT_EXT"
mkdir -p $BUILD_DIR


echo -e "${_BLUE}Bootstrapping${_RESET_COLOR}"

# Debian
mmdebstrap \
    --arch=$MISO_ARCH \
    --variant=minbase \
    --mode=auto \
    --include=linux-image-$LINUX_IMAGE_ARCH,systemd-sysv,apt-utils,zstd,gpg,wget,sudo,ca-certificates,curl,cron,$GRUB_PACKAGE \
    --components=main,contrib,non-free-firmware \
    "--customize-hook=set +e; cp -r $CHROOT_SCRIPTS_DIR \$1; echo 'cd chroot_scripts; for file in *; do [ ! -d \$file ] && [ -x \$file ] && echo && echo -e +++ Running \$file +++ && bash ./\$file; done' | chroot \$1 '/bin/bash'; set -e" \
    $MISO_VARIANT \
    $BUILD_DIR/chroot \
    http://ftp.it.debian.org/debian/


# wget -O mint-keyring.gpg "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x302F0738F465C1535761F965A6616109451BBBF2"
# gpg --no-default-keyring --keyring ./temp-m.gpg --import mint-keyring.gpg
# gpg --no-default-keyring --keyring ./temp-m.gpg --export > mint-archive-keyring.gpg
# rm temp-m.gpg
# wget -O ubuntu-keyring.gpg "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF6ECB3762474EDA9D21B7022871920D1991BC93C"
# gpg --no-default-keyring --keyring ./temp-u.gpg --import ubuntu-keyring.gpg
# gpg --no-default-keyring --keyring ./temp-u.gpg --export > ubuntu-archive-keyring.gpg
# rm temp-u.gpg
# Linux Mint
# mmdebstrap \
#     --arch=$MISO_ARCH \
#     --variant=essential \
#     --merged-usr \
#     --setup-hook='mkdir -p "$1/etc" && echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > "$1/etc/environment"' \
#     --include=linux-image-$LINUX_IMAGE_ARCH,systemd-sysv,apt-utils,zstd,gpg,wget,sudo,ca-certificates,curl,cron,$GRUB_PACKAGE,linuxmint-keyring,debianutils,coreutils,binutils \
#     --components=main,upstream,import,restricted,universe,multiverse \
#     "--customize-hook=set +e; cp -r $CHROOT_SCRIPTS_DIR \$1; echo 'cd chroot_scripts; for file in *; do [ ! -d \$file ] && [ -x \$file ] && echo && echo -e +++ Running \$file +++ && bash ./\$file; done' | chroot \$1 '/bin/bash'; set -e" \
#     wilma \
#     $BUILD_DIR/chroot \
#     "deb [signed-by=$(pwd)/mint-archive-keyring.gpg] http://packages.linuxmint.com wilma main upstream import backport" \
#     "deb [signed-by=$(pwd)/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse" \
#     "deb [signed-by=$(pwd)/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse"
# Linux Mint Debian Based
# mmdebstrap \
#     --arch=$MISO_ARCH \
#     --variant=essential \
#     --keyring=./mint-archive-keyring.gpg \
#     --include=linux-image-$LINUX_IMAGE_ARCH,dpkg,systemd-sysv,apt-utils,zstd,gpg,wget,sudo,ca-certificates,curl,cron,$GRUB_PACKAGE,linuxmint-keyring,usr-is-merged \
#     --components="main,upstream,import,backport,contrib,non-free,non-free-firmware" \
#     --setup-hook='mkdir -p "$1/usr/bin" "$1/usr/sbin" "$1/usr/lib" "$1/usr/lib64"' \
#     --setup-hook='ln -sf usr/bin "$1/bin"; ln -sf usr/sbin "$1/sbin"; ln -sf usr/lib "$1/lib"; ln -sf usr/lib64 "$1/lib64"' \
#     --customize-hook="cp -r $CHROOT_SCRIPTS_DIR \$1; chroot \$1 /bin/bash -c 'cd chroot_scripts && for file in *; do [ -x \$file ] && ./\$file; done'" \
#     faye \
#     "$BUILD_DIR/chroot" \
#     "deb [signed-by=$(pwd)/mint-archive-keyring.gpg] http://packages.linuxmint.com faye main upstream import backport" \
#     "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" \
#     "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware"
# Create directory tree
mkdir -p $BUILD_DIR/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

if [[ "$MISO_OUTPUT_EXT" = "img" ]]; then
    echo -e "${_BLUE}Creating empty img${_RESET_COLOR}"
    truncate -s $IMG_SIZE "$IMG_PATH"

    # build command string with actual newlines
    GUEST_COMMANDS="run"
    GUEST_COMMANDS+=$'\n'"part-init /dev/sda $PART_TABLE"

    if [[ "$PART_TABLE" == "gpt" ]]; then
        GUEST_COMMANDS+=$'\n'"part-add /dev/sda p 2048 104447"
        GUEST_COMMANDS+=$'\n'"part-add /dev/sda p 104448 -64" # use -64 to leave room for backup GPT
        GUEST_COMMANDS+=$'\n'"part-set-bootable /dev/sda 1 true"
        GUEST_COMMANDS+=$'\n'"mkfs vfat /dev/sda1 label:EFI"
        GUEST_COMMANDS+=$'\n'"mkfs ext4 /dev/sda2 label:root"
        GUEST_COMMANDS+=$'\n'"mount /dev/sda2 /"
        GUEST_COMMANDS+=$'\n'"mkdir /boot"
        GUEST_COMMANDS+=$'\n'"mkdir /boot/efi"
        GUEST_COMMANDS+=$'\n'"mount /dev/sda1 /boot/efi"
    else
        GUEST_COMMANDS+=$'\n'"part-add /dev/sda p 2048 -1"
        GUEST_COMMANDS+=$'\n'"part-set-bootable /dev/sda 1 true"
        GUEST_COMMANDS+=$'\n'"mkfs ext4 /dev/sda1 label:root"
        GUEST_COMMANDS+=$'\n'"mount /dev/sda1 /"
    fi

    GUEST_COMMANDS+=$'\n'"copy-in $BUILD_DIR/chroot/. /"
    GUEST_COMMANDS+=$'\n'"sh '/usr/sbin/grub-install --target=$GRUB_TARGET --removable --recheck /dev/sda'"
    GUEST_COMMANDS+=$'\n'"sh 'update-grub'"
    GUEST_COMMANDS+=$'\n'"sync"
    GUEST_COMMANDS+=$'\n'"umount-all"

    echo -e "${_BLUE}Formatting partitions and installing GRUB${_RESET_COLOR}"
    echo "$GUEST_COMMANDS" | guestfish --format=raw -a "$IMG_PATH"
else
    # Squash filesystem
    # compression algorithms available: gzip, lzo, lzma, xz, zstd
    # xz has the highest compression ration, but it's also the slowest to decompress
    # zstd is the fastest to decompress, and it's close to xz in compression ratio
    echo -e "${_BLUE}Squashing filesystem${_RESET_COLOR}"
    mksquashfs \
        $BUILD_DIR/chroot \
        $BUILD_DIR/staging/live/filesystem.squashfs \
        -b 1048576 -comp zstd \
        -noappend \
        -e boot chroot_scripts
    # proc sys run dev

    #if [[ $? -ne 0 ]]; then
    #  $MISO_SUDO rm -f "$BUILD_DIR/staging/live/filesystem.squashfs"
    #  $MISO_SUDO mksquashfs \
    #    $BUILD_DIR/chroot \
    #    $BUILD_DIR/staging/live/filesystem.squashfs \
    #    -e boot $MISO_MKSQUASHFS_MEM
    #fi

    cp $BUILD_DIR/chroot/boot/vmlinuz-* \
        $BUILD_DIR/staging/live/vmlinuz-live
    cp $BUILD_DIR/chroot/boot/initrd.img-* \
        $BUILD_DIR/staging/live/initrd.img

    echo -e "${_BLUE}Building bootloader${_RESET_COLOR}"
    tee "$BUILD_DIR/staging/isolinux/isolinux.cfg" <<EOF >/dev/null
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT normal
TIMEOUT 100
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

LABEL normal
    MENU LABEL $MISO_DISTRO_NAME ($MISO_VARIANT) $MISO_ARCH [BIOS/ISOLINUX]
    MENU DEFAULT
    KERNEL /live/vmlinuz-live
    APPEND initrd=/live/initrd.img boot=live

LABEL nomodeset
    MENU LABEL $MISO_DISTRO_NAME ($MISO_VARIANT) $MISO_ARCH [BIOS/ISOLINUX] (nomodeset)
    KERNEL /live/vmlinuz-live
    APPEND initrd=/live/initrd.img boot=live nomodeset
EOF

    tee $BUILD_DIR/staging/boot/grub/grub.cfg <<EOF >/dev/null
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "$MISO_DISTRO_NAME $MISO_ARCH [EFI/GRUB]" {
    linux (\$root)/live/vmlinuz-live boot=live
    initrd (\$root)/live/initrd.img
}

menuentry "$MISO_DISTRO_NAME $MISO_ARCH [EFI/GRUB] (nomodeset)" {
    linux (\$root)/live/vmlinuz-live boot=live nomodeset
    initrd (\$root)/live/initrd.img
}
EOF

    tee $BUILD_DIR/tmp/grub-standalone.cfg <<EOF >/dev/null
search --set=root --file /DEBIAN_CUSTOM
set prefix=(\$root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

    touch $BUILD_DIR/staging/DEBIAN_CUSTOM

    $MISO_SUDO cp /usr/lib/ISOLINUX/isolinux.bin "$BUILD_DIR/staging/isolinux/"
    $MISO_SUDO cp /usr/lib/syslinux/modules/bios/* "$BUILD_DIR/staging/isolinux/"
    $MISO_SUDO cp -r /usr/lib/grub/x86_64-efi/* "$BUILD_DIR/staging/boot/grub/x86_64-efi/"

    grub-mkstandalone \
        --format=x86_64-efi \
        --output=$BUILD_DIR/tmp/bootx64.efi \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=$BUILD_DIR/tmp/grub-standalone.cfg"

    (
        cd $BUILD_DIR/staging/EFI/boot &&
            dd if=/dev/zero of=efiboot.img bs=1M count=20 &&
            mkfs.vfat efiboot.img &&
            mmd -i efiboot.img efi efi/boot &&
            mcopy -vi efiboot.img $BUILD_DIR/tmp/bootx64.efi ::efi/boot/
    )

    echo -e "${_BLUE}Building final ISO${_RESET_COLOR}"
    xorriso \
        -as mkisofs \
        -iso-level 3 \
        -o "$BUILD_DIR/$MISO_DISTRO_NAME-$MISO_ARCH.iso" \
        -full-iso9660-filenames \
        -volid "${MISO_DISTRO_NAME^^}" \
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
fi
