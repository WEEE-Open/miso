
FROM debian:stable
# Do not install apt-utils, you just get even more errors
RUN apt-get update -y \
	&& apt-get install -y \
	sudo \
	debootstrap \
	squashfs-tools \
	dosfstools \
	xorriso \
	isolinux \
	syslinux-efi \
	syslinux \
	grub-efi-amd64-bin \
	grub-pc-bin \
	mtools \
	debian-archive-keyring \
	fakeroot \
	&& apt-get clean -y
WORKDIR /miso
# RUN debootstrap \
# 	--arch=amd64 \
# 	--variant=minbase \
# 	--include=linux-image-amd64,live-boot,systemd-sysv,apt-utils,zstd \
# 	bookworm \
# 	/miso/build/chroot \
# 	http://ftp.it.debian.org/debian/
COPY miso.sh .
COPY .env .
#ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfakeroot/libfakeroot-sysv.so
#ENV MISO_SUDO=fakeroot
ENTRYPOINT ["/bin/bash", "-c", "/miso/miso.sh"]
