#!/bin/bash
versione="V3.0 Percoca"
i=0
# Questo è lo script da eseguire dopo l'installazione di linux Mint XFCE in modalità OEM sulla Golden Image

echo USERNAME IS $MISO_USERNAME

#qualche controllino
sudo echo -en "\e[0;1m"
while ! wget -q --tries=10 --timeout=20 --spider http://weeeopen.polito.it/
do
  whiptail --title "Errore!" --msgbox "Non riesco a connettermi ad Internet! \nControlla la connessione, WEEEino caro." 10 65
done
while sudo fuser /var/lib/dpkg/lock > /dev/null 2>&1
do
  if [ $i -ge 5 ]
  then
    i=0
    if ! whiptail --title "dpkg occupato" --yesno "dpkg è già in esecuzione, quindi non posso continuare.\nVuoi provare con la forza bruta? [Sconsigliato]" --yes-button "Riprova" --no-button "Uccidi apt" 10 65
    then
      sudo fuser -vk /var/lib/dpkg/lock > /dev/null
      sudo dpkg --configure -a > /dev/null
    fi
  else
    i=$(( $i + 1 ))
    if ! whiptail --title "dpkg occupato" --yesno "dpkg è già in esecuzione, quindi non posso continuare.\nTi consiglio di riprovare più tardi o di riavviare il PC." --yes-button "Riprova" --no-button "Riavvia" 10 65
    then
      reboot
      exit -1
    fi
  fi
done

#inizio
echo -e "Benvenutǝ nella \e[33m🍑 \e[0;1m"$versione"!"
nome="Weeeino" #$(whiptail --inputbox "Come ti chiami?" --nocancel 10 65 "WEEEino a caso"  3>&1 1>&2 2>&3)
killall light-locker > /dev/null 2>&1
sudo apt update > /dev/null 2>&1
#verifico se è stata già eseguita.
echo -en "\e[31mAttivo aggiornamento orario tramite NTP...\e[0;1m"
sudo apt install systemd-timesyncd -y 2>/dev/null >/dev/null
echo NTP=ntp1.inrim.it ntp2.inrim.it | sudo tee -a /etc/systemd/timesyncd.conf > /dev/null
sudo timedatectl set-ntp true
echo -e "\t\t\t\t\e[92m✔️"
echo -en "\e[32mInstallo motd e tema Plymouth...\e[0;1m"
cp -r /home/$MISO_USERNAME/pesca/weee-logo/ /usr/share/plymouth/themes/weee-logo
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/weee-logo/weee-logo.plymouth 100 #2>/dev/null >/dev/null
update-alternatives --set default.plymouth /usr/share/plymouth/themes/weee-logo/weee-logo.plymouth #2>/dev/null >/dev/null
update-initramfs -u
cp /home/$MISO_USERNAME/pesca/01-weeeopen /etc/update-motd.d/01-weeeopen
chown root:root /etc/update-motd.d/01-weeeopen
chmod 755 /etc/update-motd.d/01-weeeopen
#imposto la swappiness a 25
echo vm.swappiness=25 | sudo tee -a /etc/sysctl.conf > /dev/null
echo -e "\t\t\t\t\t\e[92m✔️"
echo -en "\e[32mScarico ed installo gli sfondi...\e[0;1m"
sudo -u "$MISO_USERNAME" wget https://github.com/WEEE-Open/pesca/releases/download/V3.0/sfondeee_1.0_all.deb -O /home/$MISO_USERNAME/sfondeee_1.0_all.deb
apt install /home/$MISO_USERNAME/sfondeee_1.0_all.deb
# cp /home/$MISO_USERNAME/pesca/xfce4-desktop.xml /etc/xdg/xdg-xfce/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo -e "\t\t\t\t\t\e[92m✔️"
echo -en "\e[32mCopio link sul desktop...\e[0;1m"
sudo -u "$MISO_USERNAME" mkdir -p /home/$MISO_USERNAME/Desktop
sudo -u "$MISO_USERNAME" cp /home/$MISO_USERNAME/pesca/'Gandalf 10 hours.desktop' /home/$MISO_USERNAME/Desktop/
sudo -u "$MISO_USERNAME" cp /home/$MISO_USERNAME/pesca/'StressCPU.desktop' /home/$MISO_USERNAME/Desktop/
echo "Path=/home/$MISO_USERNAME/pesca/" >> /home/$MISO_USERNAME/Desktop/StressCPU.desktop
sudo -u "$MISO_USERNAME" cp /home/$MISO_USERNAME/pesca/'StressGPU.desktop' /home/$MISO_USERNAME/Desktop/
echo -e "\t\t\t\t\t\t\e[92m✔️"

echo -en "\e[33mAggiorno il software."
dpkg --configure -a
apt --fix-broken install
# sudo xterm -geometry 80x24-0-0 -e apt install oneko -y
# echo -en "\e[33m Nel frattempo gioca pure con questo gattino...\e[0;1m"
# oneko -bg green&
apt full-upgrade -y
# if [ "$laprima" -eq 0 ]
# then
#   if (whiptail --yesno --defaultno "Vuoi installare altri software?" 8 78)
#   then
#     tobeinstalled=$(whiptail --inputbox "Separa con uno spazio i software che vuoi installare" --nocancel 10 65 "$(cat lista-software)" 3>&1 1>&2 2>&3)
#     sudo xterm -geometry 80x24-0-0 -e apt install $tobeinstalled -y
#   fi
# else
#   tobeinstalled=$(whiptail --inputbox "Separa con uno spazio i software che vuoi installare" --nocancel 10 65 "$(cat lista-software)" 3>&1 1>&2 2>&3)
#   sudo xterm -geometry 80x24-0-0 -e apt install $tobeinstalled ssh -y
# fi
#prima di spedire il pc disabilito ssh e cambio il fingerprint
# sudo sed -i 's/\/bin\/systemctl enable oem-config.service/\/bin\/systemctl disable ssh\n\t\/bin\/systemctl enable oem-config.service/' /usr/sbin/oem-config-prepare
sudo ssh-keygen -A 2>/dev/null >/dev/null
echo -e "\t\e[92m✔️"
# echo -en "\e[94mPulisco i pacchetti orfani...\e[0;1m"
# killall oneko
# sudo xterm -geometry 80x24-0-0 -e apt autoremove oneko --purge -y
# svuoto il journal
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s 2>/dev/null > /dev/null
# riduco lo spazio risevato
# sudo tune2fs -m 0 /dev/sda1 > /dev/null
# echo -e "\t\t\t\t\t\t\e[92m✔️"
# echo -en "\e[94mAdeguo la swap alla quantità di RAM "
# ram="$(cat /proc/meminfo | grep MemTotal | awk {'print $2'})"
# echo -en "$((${ram}/1000)) MiB ...\e[0;1m"
# swapoff /swapfile
# fallocate -l ${ram}K /swapfile
# mkswap /swapfile 2>/dev/null > /dev/null
# mkswap /swapfile 2>/dev/null > /dev/null
# swapon /swapfile
echo -e "\t\t\t\e[92m✔️"
echo -e "\e[1;92mFinito.\e[0m"
# read response
# exit 0
