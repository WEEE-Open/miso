#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== Final cleanup ==="
# Remove unused packages
apt-get autoremove -y
# Clean the cache
apt-get clean -y
rm -rf /var/lib/apt/lists/*

echo "=== Set hostname part 2 ==="
cat <<EOF >/etc/hosts
127.0.0.1       localhost $MISO_HOSTNAME
::1             localhost ip6-localhost ip6-loopback $MISO_HOSTNAME
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

echo "=== Set desktop shortcuts as trusted ==="
echo "@reboot weee f=/home/$MISO_USERNAME/Desktop/*.desktop; gio set -t string \$f metadata::xfce-exe-checksum \$(sha256sum \$f | awk '{print \$1}')" >/etc/cron.d/trust_desktop_shortcuts
