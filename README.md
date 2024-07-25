# M.I.S.O.

*Marchingegno per Iso del Sistema Operativo*

Build Debian Live images, with the maximum amount of automation

## Usage

```shell
docker build -t weee-open/miso:latest .
docker run --name miso \
  -i --rm \
  -v $(readlink -f build):/build:rw \
  -v $(readlink -f weeedebian):/weeedebian:ro \
  -e MISO_BUILD_DIR=/build \
  -e MISO_CHROOT_SCRIPT=/weeedebian/martello.sh \
  -e MISO_HOSTNAME=weeedebian \
  -e MISO_ROOTPASSWD=asd \
  -e MISO_USERNAME=weee \
  -e MISO_USERPASSWD=asd \
  -e MISO_ARCH=amd64 \
  -e MISO_CONTAINER=true \
  weee-open/miso:latest
```

Also useful if you don't have an endless amount of RAM: `-e MISO_MKSQUASHFS_MEM=500m \`

This will output weeedebian-amd64.iso into build/weeedebian.

On a Debian/Ubuntu machine, you can run the script without any container:

```shell
# Install dependencies
./install_dep.sh
./miso.sh build weeedebian/martello.sh amd64
# Uninstall dependencies if you want to save space
./uninstall_dep.sh
```

This also works on WSL.

### Requirements

Checklist:

* Docker (or Podman, or Ubuntu on WSL)
* M.I.S.O.
* A [Tarallo](https://github.com/WEEE-Open/tarallo) token (optional)
* A bit of asd

Get the Tarallo token and create a file named `env.txt` inside `weeedebian` with this content:

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
