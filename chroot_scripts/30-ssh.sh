#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== SSH daemon configuration ==="
sudo tee /etc/ssh/sshd_config <<EOF
#       $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $
# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

echo "=== s.sh ==="
sudo tee /usr/sbin/s.sh <<EOF
#!/bin/bash
# enable and start sshd, print local IP and interface

set -u

# systemctl enable --now sshd
if sudo systemctl start sshd ; then
    echo "ssh service started sucessfully."
    _INT=$(ip -4 route | awk '/^default/ {print $5}')
    _IPV4=$(ip addr show $_INT | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "Your local address is $_IPV4 on interface $_INT"
else
    echo "ssh service failed to start."
fi

read -p "Press enter to close"

EOF
chmod +x /usr/sbin/s.sh
# sudo -u $MISO_USERNAME cp ./ssh.desktop /home/$MISO_USERNAME/Desktop
# sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/ssh.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/ssh.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/ssh.desktop | awk '{print $1}')"
