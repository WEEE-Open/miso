#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== Modules configuration ==="
_MODULES=("eeprom" "at24" "ee1004" "i2c-i801")
for i in ${!_MODULES[@]}; do
    if [[ ! -f "/etc/modules-load.d/${_MODULES[$i]}.conf" ]]; then
        printf "${_MODULES[$i]}\n" >/etc/modules-load.d/${_MODULES[$i]}.conf
    fi
done
