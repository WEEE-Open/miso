# M.I.S.O.

*Marchingegno per Iso del Sistema Operativo*

Build Debian Live images, with the maximum amount of automation

## Usage

Appropriately configure the `.env` file. 
Also useful if you don't have an endless amount of RAM: `MISO_MKSQUASHFS_MEM=500m`

If needed, customization can be done by modifying or adding files in the directory `chroot_scripts`. They must be marked as executable.

To build the iso, run

```shell
docker compose up --build
```
This will output weeedebian-{MISO_ARCH}.iso into build/weeedebian-{MISO_ARCH}.

On a Debian/Ubuntu machine, you could also run the script without any container:
```shell
# Install dependencies
./install_dep.sh
./miso.sh
# Uninstall dependencies if you want to save space
./uninstall_dep.sh
```

This also works on WSL (Untested).

### Requirements

Checklist:

* Docker (or Podman, or Ubuntu on WSL)
* M.I.S.O.
* A [Tarallo](https://github.com/WEEE-Open/tarallo) token (optional)
* A bit of asd

To configure TARALLO, just add these two keys to the `.env` file
```text
export TARALLO_URL=http://127.0.0.1:8080
export TARALLO_TOKEN=yoLeCHmEhNNseN0BlG0s3A:ksfPYziGg7ebj0goT0Zc7pbmQEIYvZpRTIkwuscAM_k
```

Substitute the URL and token with actual values, that's just an example token which will not work in production.  
This will be used by the Peracotta.

## Known issues

The red warning about missing apt-utils in container build can be ignored, installing apt-utils causes even more warnings which do not affect anything.

This one inside the bootstrap process can be ignored, too:

```
W: Failure trying to run: chroot "/build/weeedebian-amd64/chroot" mount -t proc proc /proc
W: See /build/weeedebian-amd64/chroot/debootstrap/debootstrap.log for details
W: Failure trying to run: chroot "/build/weeedebian-amd64/chroot" mount -t sysfs sysfs /sys
W: See /build/weeedebian-amd64/chroot/debootstrap/debootstrap.log for details
```

That stuff doesn't work with the combination of a container and a chroot, unless you want to elevate your container privileges.
