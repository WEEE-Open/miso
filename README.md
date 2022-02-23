# M.I.S.O.

*Marchingegno per Iso del Sistema Operativo*

Build Debian Live images, with the maximum amount of automation

## Usage

```shell
docker build -t weee-open/miso:latest
docker run -i --name miso --mount build:/build --mount weeedebian_files:/weeedebian_files:ro
```

On a Ubuntu WSL machine, instead of a container, you can do:

```shell
apt-get update
apt-get -y install live-build
sudo mkdir -p /miso
ln -s /path/to/build /build
ln -s /path/to/weeedebian_files /weeedebian_files
ln -s /path/to/miso_maker.sh /miso
/miso/miso_maker.sh
```

More info coming soon (still work in progress)

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

### 64-bit

TBD

### 32-bit

TBD
