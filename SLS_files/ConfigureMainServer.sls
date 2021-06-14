apt install -y build-essential apache2 php openssl perl make php-gd libgd-dev libapache2-mod-php libperl-dev libssl-dev daemon wget apache2-utils unzip:
  cmd.run
create_users:
  cmd.run:
    - names:
        - useradd nagios
        - groupadd nagcmd
        - usermod -a -G nagcmd nagios
        - usermod -a -G nagcmd www-data
extract_nagios:
  cmd.run:
    - cwd: /tmp
    - names:
        - wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.5.tar.gz
        - tar -zxvf /tmp/nagios-4.4.5.tar.gz
install_nagios:
  cmd.run:
    - cwd: /tmp/nagios-4.4.5/
    - names:
        - ./configure --with-nagios-group=nagios --with-command-group=nagcmd --with-httpd_conf=/etc/apache2/sites-enabled/
        - make all
        - make install
        - make install-init
        - make install-config
        - make install-commandmode
        - make install-webconf
/usr/local/nagios/etc/htpasswd.users:
  file.managed:
    - source: salt://files/nagios/htpasswd.users
a2enmod cgi:
  cmd.run
systemctl restart apache2:
  cmd.run
install_nagios_plugins:
  cmd.run:
    - cwd: /tmp
    - names:
       - wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
       - tar -zxvf /tmp/nagios-plugins-2.3.3.tar.gz
Configure_Nagios_plugins:
  cmd.run:
    - cwd: /tmp/nagios-plugins-2.3.3/
    - names:
        - ./configure --with-nagios-user=nagios --with-nagios-group=nagios
        - make
        - make install
start-nagios:
  cmd.run:
    - names:
       - systemctl enable nagios
       - service nagios start
mkdir /usr/local/nagios/etc/servers/:
  cmd.run
syslog-ng:
  pkg.installed
syslog-ng.conf: 
  file.managed:
    - name: /etc/syslog-ng/conf.d/syslog.conf
    - source: salt://files/syslog-ng/server
    - replace: true
service syslog-ng restart:
 cmd.run
