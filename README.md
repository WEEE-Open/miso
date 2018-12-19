<h1>F.A.L.C.E.</h1>
Fondamentale Armamentario per la Lavorazione di Custom ISO per le Evenienze
<br>Build a custom ISO with JLIVECD without annoying interactive prompts

<h2>Usage</h2>

```
usage: falce [-h] [-n] [-c CONF] [-l LABEL] [-a] [-r] [-f] [-u] [-b] [-w]
               [--verbose]
               project_path iso_path

F.A.L.C.E.: Fondamentale Armamentario per la Lavorazione di Custom ISO per le Evenienze. Build a custom ISO with JLIVECD without annoying interactive
prompts

positional arguments:
  project_path          Specify the (FULL) path where your project is (or will
                        be) saved. This is a required option

optional arguments:
  -h, --help            show this help message and exit
  -n, --new             Specify whether you are opening a new project or an
                        existing one. The default value is False
  -c CONF, --conf CONF  Specify a JLIVECD configuration file (usually it is
                        generated when you create a project, but there are
                        three example configuration files if you need them.
                        The default value is ''. Note that using a
                        configuration file will cause the script to ignore
                        eventual command line arguments.
  -l LABEL, --label LABEL
                        Specify the ISO label (default is 'soviet'
  -a, --access-control  Prevent access control. Doing it will prevent GUI apps
                        to run. The default value is False
  -r, --retain-home     Keep the contents of the home folder when building the
                        ISO. The default value is True
  -f, --fast-compression
                        Use fast compression when build the squashfs live
                        filesystem. Using it will produce a bigger ISO. The
                        default value is False.
  -u, --uefi            Specify whether to build a UEFI image. The default
                        value is False.
  -b, --hybrid          Specify whether to build a hybrid image (it means it
                        can be booted from disk storage devices). The default
                        value is False.
  -w, --write-conf      Write current settings to project config
  --verbose, -v         Specify the verbosity level
  --iso-path              Specify the (FULL) path where the ISO you want to
                        customize is stored. The default value is ''
  -x, --execute-chroot  Specify a command (or a script) to execute in the chroot environment. Note that an eventual
                        custom script can be executed by placing it in a folder and add it with the --add-folder argument                
  --add-folder          Specify a temporary folder that will be available in the chroot environment's root directory
```

Example configuration files are provided.

<h2>WEEEDebian build</h2>

Checklist:

* A brand new Debian live ISO
* [JLIVECD]("https://github.com/neurobin/JLIVECD")
* F.A.L.C.E.
* A bit of asd

32-bit:
```
sudo falce -n --add-folder weeedebian_files -x /weeedebian_files/martello.sh -n \
-l weeedebian_i386 -c WEEEDebian/WEEEDebian_i386.conf \
--iso-path /path/to/iso /path/to/project/folder
```
64-bit:
```
sudo falce -n --add-folder weeedebian_files -x /weeedebian_files/martello.sh -n \
-l weeedebian_files -c WEEEDebian/WEEEDebian_amd64_nouefi.conf \
--iso-path /path/to/iso /path/to/project/folder
```
<h2>TODO</h2>

* Add comments
* Allow kernel customization
* Add support for Ubuntu and Arch
* Give some purpose to -v argument
* Handle exceptions
