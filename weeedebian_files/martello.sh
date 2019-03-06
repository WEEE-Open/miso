#!/bin/bash
# WEEEDebian creation script - a-porsia
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"
# For some reason (I checked and it's JLIVECD's fault, the F.A.L.C.E. is actually perfect asd) the script gets executed two times
# So it's necessary to ask whether the user wants to execute the script or not
read -p 'Execute martello.sh? [y/n]: ' ans
if [[ $ans == "y" ]]; then

    sudo -H -u root /bin/bash -c 'apt update -y && apt install -y i2c-tools lshw smartmontools cifs-utils dmidecode pciutils gvfs-backends'
    if [[ -z `grep eeprom /etc/modules-load.d/eeprom.conf` ]]; then
        printf "eeprom\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep at24 /etc/modules-load.d/eeprom.conf` ]]; then
        printf "at24\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep weee /etc/passwd` ]]; then
        if [[ -d "/home/weee" ]]; then
            rm -rf "/home/weee"
        fi
        adduser weee
        adduser weee sudo
        passwd weee
    fi
    # Moves scriptino.sh from custom folder
    sudo -H -u root chmod +x /weeedebian_files/scriptino.sh
    sudo -H -u root mv /weeedebian_files/scriptino.sh /usr/bin/scriptino
    sudo -H -u root rsync -a -r --force /weeedebian_files/xfce4 /home/weee/.config/xfce4
    sudo -H -u weee setxkbmap it
    sudo -H -u root mkdir /etc/systemd/system/getty@.service.d
    sudo -H -u root touch /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=\n" > /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" > /etc/systemd/system/getty@.service.d/override.conf 
    # Starts an xfce4 session if you need to modify xfce4 settings for user weee
    read -p 'Start xfce4 (Press Ctrl+C in this terminal to close it) [y/n]?: ' ans
        if [[ $ans == "y" ]]; then
            sudo -H -u weee /bin/bash -c 'xfce4-panel'
        fi
else
    exit
fi
# TODO: add a link to Tarallo
