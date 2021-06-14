sudo apt install -y software-properties-common:
  cmd.run
php-ppa:
  pkgrepo.managed:
    - ppa: ondrej/php
apt update:
  cmd.run
nginx:
  pkg.installed
ufw allow 'Nginx Full':
  cmd.run
mysql-server:
  pkg.installed
debconf-utils:
  pkg.installed
php_installation:
  pkg.installed:
    - pkgs:
      - php7.2
      - php7.2-cli
      - php7.2-fpm
      - php7.2-mysql
      - php7.2-json
      - php7.2-opcache
      - php7.2-mbstring
      - php7.2-xml
      - php7.2-gd
      - php7.2-curl
/etc/mysql/my.cnf:
  file.managed:
    - source: salt://files/mysql/my.cnf.temp
    - replace: True
  #file.append:
  #  - text:
  #    - [mysqld]
  #    - skip-grant-tables
  #    - [local]
  #    - user = root
  #    - host = localhost
  #   - password = temp
#my.cnf-home:
#   file.managed:
#     - name: ~/.my.cnf
#     - source: salt://files/mysql/my.cnf
service mysql restart:
  cmd.run
  mysql_setup:
    debconf.set:
      - data:
          'mysql-server/root_password': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql:root_pw', '') }}' }
          'mysql-server/root_password_again': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql:root_pw', '') }}' }
      - require:
        - pkg: debconf-utils
  #wordpress:
  #  mysql_database.present:
  #    - name: wordpress
  mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;":
    cmd.run
  mysql -e "CREATE USER 'wordpressuser'@'%' IDENTIFIED WITH mysql_native_password BY '{{ salt['pillar.get']('mysql:root_pw', '') }}'":
    cmd.run
  mysql -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'%';":
    cmd.run
  #sudo mysql -e "create database IF NOT EXISTS wordpress": cmd.run
  #WordPressUser: 
  #  mysql_user.present:
  #    - name: WordPressUser
  #    - host: localhost
  #    - password: P@SSw0rd!
  #    - connection_pass: P@SSw0rd!
  #sudo mysql -e "CREATE USER 'WordPressUser'@'localhost' IDENTIFIED BY 'password'": cmd.run
  #WordPress_grant:
  #  mysql_grants.present:
  #    - grant: ALL PRIVILEGES
  #    - database: wordpress.*
  #    - user: WordPressUser
  #    - host: localhost
  mysql -e "GRANT ALL ON WordPress.* TO WordPressUser @'localhost'":
    cmd.run
  #sudo mysql -e "GRANT ALL ON wordpress.* TO WordPressUser @'localhost'":
  #  cmd.run
  my.cnf:
    file.managed:
     - name: /etc/mysql/my.cnf
     - source: salt://files/mysql/my.cnf
     - replace: True
  final_restart:
    cmd.run:
      - name: service mysql restart
WordPress_source:
  file.managed:
    - name: /home/merlijn/latest.tar.gz
    - source: salt://files/wordpress/latest.tar.gz
extract_wordpress:
  cmd.run:
    - cwd: /home/merlijn
    - names:
        - tar xf latest.tar.gz
        - chown root:root /home/merlijn/wordpress -R
move_wordpress:
  cmd.run:
    - cwd: /home/merlijn
    - names:
       - mkdir -p /var/www/html/sample.com
       - cp -rf wordpress/* /var/www/html/sample.com/
Configure_nginx:
  file.managed:
    - name: /etc/nginx/sites-enabled/default
    - source: salt://files/nginx/default
    - replace: True
wp_config:
  file.managed:
    - name: /var/www/html/sample.com/wp-config.php
    - source: salt://files/wordpress/wp-config.php
    - replace: True
service nginx restart:
  cmd.run
apt install -y  docker.io:
  cmd.run
systemctl enable --now docker:
  cmd.run
sudo docker volume create --name storage:
  cmd.run
docker run -d --name fileserver -v storage:/web -p 8080:8080 halverneus/static-file-server:latest:
  cmd.run
Copy_and_run__nagios_script:
  cmd.script:
    - name: nagiosConfig.sh
    - source: salt://files/nagios/nagiosConfig.sh
Get_nagios_config:
  module.run:
    - name: cp.push
    - path: /tmp/config.cfg
