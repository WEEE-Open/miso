# syntax=docker/dockerfile:1
FROM debian:stable-slim
MAINTAINER WEEE Open
RUN apt-get update \
    && apt-get install \
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
    && apt-get clean
WORKDIR /miso
COPY miso.sh .
ENTRYPOINT ["/miso/miso.sh", "/build"]
