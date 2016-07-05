#!/usr/bin/env bash

set -e


## Install Basics + MySQL
yum install -y -qq httpd php php-cli php-mysql php-curl &> /dev/null

set +e
yum info mariadb-server &> /dev/null
HASMARIA=$?
set -e

if [ $HASMARIA -eq 0 ]; then
    yum install -y mariadb-server &> /dev/null
    chkconfig mariadb on &> /dev/null
    service mariadb start &> /dev/null
else
    yum install -y mysql-server &> /dev/null
    chkconfig mysqld on &> /dev/null
    service mysqld start &> /dev/null
fi

## Enable & Start Services

chkconfig httpd on &> /dev/null
service httpd start &> /dev/null

## Configure MySQL
! read -d '' MYSQLTEMPLATE << EOF
[client]
host=localhost
user=root
EOF

echo "$MYSQLTEMPLATE" > /root/.my.cnf

# TODO: Not created (but ok since use sudo)
if [ ! -z "$HOME" ]; then
    echo "$MYSQLTEMPLATE" > $HOME/.my.cnf
fi

# TODO: CentOS 6 instals mysql 5.1, no utf8m4 charset
mysql -e "CREATE DATABASE IF NOT EXISTS helpspot_db CHARSET utf8mb4 collate utf8mb4_unicode_ci;"

## Configure Apache
! read -d '' APACHETEMPLATE << EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/helpspot

    <Directory /var/www/helpspot>
        Options -Indexes +FollowSymLinks +MultiViews
        # Disallow .htaccess file usage:
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/helpspot/data>
        # Disallow web access to "data" directory:
        Deny from all
    </Directory>

    ErrorLog /var/log/httpd/support.example.com-error.log
    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg. LogLevel warn
    CustomLog /var/log/httpd/support.example.com-access.log combined
</VirtualHost>

EOF

echo "$APACHETEMPLATE" > /etc/httpd/conf.d/vhost.conf
service httpd reload &> /dev/null
echo "Complete!"
