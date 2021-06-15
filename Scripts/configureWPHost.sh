#!/bin/sh
salt $1 state.apply ConfigureWPHost
salt $1 state.apply logging_client 

for dir in /var/cache/salt/master/minions/*; do 
  salt-cp main03-mv-404160.internal.cloudapp.net "$dir"/files/tmp/config.cfg /usr/local/nagios/etc/servers/$(basename "$dir").cfg 
done
salt main03-mv-404160.internal.cloudapp.net cmd.run "systemctl restart nagios.service"
