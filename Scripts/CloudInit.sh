#!/bin/bash 
# Install salt minion 
apt-get update -y 
curl -L https://bootstrap.saltstack.com/ -o install_salt.sh 
sh install_salt.sh 
apt-get upgrade -y 

# Set salt master location and start minion

echo "master: 10.0.6.84" >> /etc/salt/minion 
salt-minion -d 
systemctl restart salt-minion.service
