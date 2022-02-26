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
  -e MISO_CHROOT_SCRIPT=/weeedebian/martello.sh \
  -e MISO_HOSTNAME=weeedebian \
  -e MISO_ROOTPASSWD=asd \
  -e MISO_USERNAME=weee \
  -e MISO_USERPASSWD=asd \
  -e MISO_ARCH=amd64 \
  -e MISO_NO_SUDO=1 \
  weee-open/miso:latest

# To save some time if you need to re-run to update the image,
# add MISO_NO_BOOSTRAP to save some time:
docker run --name miso \
  -i --rm \
  -v $(readlink -f build):/build:rw \
  -v $(readlink -f weeedebian):/weeedebian:ro \
  -e MISO_CHROOT_SCRIPT=/weeedebian/martello.sh \
  -e MISO_HOSTNAME=weeedebian \
  -e MISO_ROOTPASSWD=asd \
  -e MISO_USERNAME=weee \
  -e MISO_USERPASSWD=asd \
  -e MISO_ARCH=amd64 \
  -e MISO_NO_SUDO=1 \
  -e MISO_NO_BOOSTRAP=1 \
  weee-open/miso:latest
```

This will output weeedebian-amd64.iso into build/weeedebian.

On a Debian/Ubuntu machine, you can run the script without any container:

```shell
# Install dependencies
./install_dep.sh
mkdir build
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

Get the Tarallo token and create a file named `env.txt` inside `weeedebian_files` with this content:

```text
export TARALLO_URL=http://127.0.0.1:8080
export TARALLO_TOKEN=yoLeCHmEhNNseN0BlG0s3A:ksfPYziGg7ebj0goT0Zc7pbmQEIYvZpRTIkwuscAM_k
```

Substitute the URL and token with actual values, that's just an example token which will not work in production.  
This will be used by the Peracotta.
