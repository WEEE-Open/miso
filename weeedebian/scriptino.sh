#!/bin/bash
# Short script from Dave

if [[ $EUID -ne 0 ]]; then
   echo "Run me as root!" 1>&2
   exit 1
fi

shopt -s nocasematch
LIST_OF_APPS="lshw lspci dmidecode smartctl decode-dimms"
declare -A LIST_PACKAGES=( ["smartctl"]="smartmontools" ["decode-dimms"]="i2c-tools" ["dmidecode"]="dmidecode" ["lshw"]="lshw" ["lspci"]="pciutils")
declare -A LIST_COMMAND=( ["lshw"]="lshw" ["dmidecode"]="dmidecode" ["smartctl"]="smartctl -x /dev/sda" ["decode-dimms"]="decode-dimms" ["lspci"]="lspci -v")
echo "Esecuzione scriptino piccolo e carino"

for prog in $LIST_OF_APPS; do
	if hash $prog 2>/dev/null; then
        	echo "$prog installed."
    	else
        	echo -n "$prog is not installed. Do you want to install it? (Y/N) "
		read prog_installation
		if [[ $prog_installation == "y" ]]; then
    			echo "Installing $prog"
			apt install ${LIST_PACKAGES[$prog]} -y
			echo "Installation complete."
		else
   	 		echo "Not installing. I cannot proceed. Exiting."
			exit 1
		fi
    	fi
done

if [ -z "$1" ]; then
	echo -n "Inserisci il nome del file: "
	read FILE_NAME
	FILE_VAR="$PWD/$FILE_NAME.txt"
	touch $FILE_VAR
	echo "File created $FILE_VAR"
else
	FILE_VAR="$PWD/$1.txt"
	touch $FILE_VAR
	echo "File created $FILE_VAR"
fi

# Allow everyone to access the file, because sudo (or su)
chmod 666 $FILE_VAR
# Will chown to the regular user if called with sudo.
chown "$(logname)" $FILE_VAR

modprobe at24
modprobe eeprom

for prog in $LIST_OF_APPS; do
	echo "Exec command $prog" 
	${LIST_COMMAND[$prog]} >> $FILE_VAR
done

echo "END"
