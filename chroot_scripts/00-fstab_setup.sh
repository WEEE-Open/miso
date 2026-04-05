#!/bin/bash
#set -x
#set -e

# this has to be done before sudo
echo "=== Set fstab ==="
cat <<EOF > /etc/fstab
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
LABEL=root    /               ext4    errors=remount-ro 0       1
EOF
