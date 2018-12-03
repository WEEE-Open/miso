# Creating a custom Debian live disk with JLIVECD

There are three possible cases:
* You are using Windows
* You are using Arch Linux or an Arch-based distro
* You are using a different distro, like Debian or Fedora

If you are using Windows, then go away, you're in the wrong place.
If you are using a distro different from Arch or an Arch-based distro, then go
away, you're still in the wrong place.
If you are using Arch Linux or an Arch-based distro, then may the Free Software
Gods bestow their blessing upon thee.

Apart from jokes, this procedure has been tested on Arch Linux, so it may have
unexpected behavior when using a different distro. But if you're using Windows
then you are **really** in the wrong place.

If you haven't done it yet, clone [JLIVECD](https://github.com/neurobin/JLIVECD) and follow the instructions in
the README.md to install it and learn how to use it. It is fairly simple, so I
will omit how to use it, given that JLIVECD guides you through the entire procedure.
When you're done and you have your shiny new JLIVECD, there are still a couple
of things to do to make it work properly with UEFI-bootable hybrid ISO images.
(_**hybrid**: can be booted from a disk storage device like a USB drive_)
If you don't want to build a UEFI-bootable hybrid ISO, then skip the following lines.

JLIVECD uses genisoimage (and consequently mkisofs) to generate the ISO, but if
you're planning to make it UEFI-bootable, JLIVECD will fail because, for some
reason I don't understand, passes to genisoimage (mkisofs) the '*-e*' option,
which genisoimage (mkisofs) doesn't recognize, and exits with this error:
```
Bad Option '-e' (error -1 BADFLAG).
```
So, instead of searching through the whole JLIVECD source code we can just
ignore the error and do the last steps on our own (head to the UEFI hybrid ISO section below).

Once JLIVECD is installed, open a terminal and enter the following command:
```
sudo JLstart -db
```
The '-db' option stands for 'Debian'.
Now JLIVECD will guide you through the procedure to build your custom live ISO.
But, there's a but: once you get to the chroot part, where you can freely screw
things up in your live filesystem, there may be some problems.
If you use a shell different from bash, chroot will fail because it will look
for the shell you are using by default in your system. For example I use zsh,
but chroot can't find zsh in the Debian ISO live filesystem.
So, exit the chroot environment, close everything and cd into the project's
directory:
```
cd YOUR_PROJECT_DIRECTORY
```
Open the config.conf file you find there, find the 'CHROOT' entry, uncomment it
and add '/bin/bash' at the end.
Now the chroot part will run smoothly and you'll be able to screw things up and
end up destroying everything and burning in hell.

Another problem may be the presence of spaces in the 'DISKNAME' entry. Just find
it, uncomment it and remove eventual spaces, or enclose the value in double quotes,
or do whatever you want, just follow a simple rule: NO SPACES IN 'DISKNAME'!
If you don't do that, JLIVECD will probably fail to build the ISO image.

Last but not least, if you are planning to update and/or modify the kernel,
follow the instructions on JLIVECD's wiki.

## UEFI hybrid ISO

First, you have to install xorriso, so open a terminal and enter the following:
```
sudo pacman -S xorriso
```
(Adjust the command according to your distro).

Then cd into the folder where JLIVECD stores the contents of the custom ISO:
```
cd PROJECT_FOLDER/extracted
```
and enter the following command (substitute ISO_NAME with whatever you want):
```
sudo xorriso -as mkisofs -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level
4 -b isolinux/isolinux.bin -c isolinux/boot.cat -eltorito-alt-boot -e
boot/grub/efi.img -no-emul-boot -o ../ISO_NAME.iso .

sudo isohybrid --uefi ../ISO_NAME.iso
```
And now you have your UEFI-bootable hybrid ISO image.
