
FROM debian:stable-slim
# Do not install apt-utils, you just get even more errors
RUN apt-get update -y \
    && apt-get install -y \
	    debootstrap \
	    squashfs-tools \
    	dosfstools \
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
ENTRYPOINT ["/miso/miso.sh", "/build"]
COPY miso.sh .
