# syntax=docker/dockerfile:1
FROM debian:stable-slim
MAINTAINER WEEE Open
RUN apt-get update -y \
    && apt-get install -y \
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
	    syslinux \
    && apt-get clean -y
WORKDIR /miso
COPY miso.sh .
ENTRYPOINT ["/miso/miso.sh", "/build"]
