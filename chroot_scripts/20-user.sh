#!/bin/bash

#set -x
set -e

echo "=== User configuration ==="
# openssl has been installed, so this can be done now
MISO_ROOTPASSWD=$(openssl passwd -6 "$MISO_ROOTPASSWD")
MISO_USERPASSWD=$(openssl passwd -6 "$MISO_USERPASSWD")
if [[ -z $(grep weee /etc/passwd) ]]; then
    useradd -m -G sudo -s /bin/zsh weee
fi
# The -p parameter is silently ignored for some reason:
# -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
# This ALSO does not work:
#echo "weee:asd" | chpasswd
# So...
sed -i "s#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#" /etc/shadow
sed -i "s#$MISO_USERNAME:.*#$MISO_USERNAME:$MISO_USERPASSWD:18214:0:99999:7:::#" /etc/shadow
