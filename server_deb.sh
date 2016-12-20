#!/usr/bin/env bash

set -e


## Install Basics
apt-get update &> /dev/null
apt-get install -y -qq nginx php7.0-fpm php7.0-cli php7.0-mysql php7.0-curl php7.0-xml php7.0-gd php7.0-intl php7.0-imap &> /dev/null

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

apt-get install -y -qq mysql-server &> /dev/null

## Configure MySQL
! read -d '' MYSQLTEMPLATE << EOF
[client]
host=localhost
user=root
password=root
EOF

echo "$MYSQLTEMPLATE" > /root/.my.cnf

if [ ! -z "$HOME" ]; then
    echo "$MYSQLTEMPLATE" > $HOME/.my.cnf
fi

mysql -e "CREATE DATABASE IF NOT EXISTS helpspot_db CHARSET utf8mb4 collate utf8mb4_unicode_ci;"

## Configure Nginx
## TODO: php-fpm parameters include file different per version
##       debian/ubuntu/nginx installed
! read -d '' NGINXTEMPLATE << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www/helpspot;
    index index.html index.htm index.php;

    server_name _;

    location / {
            try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \\.php\$ {
            # nginx 1.10.* / ubuntu 16.04 default
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;

            # debian 8 default
            ## include snippets/fastcgi-php.conf;
            ## fastcgi_pass unix:/var/run/php7.0-fpm.sock;
    }
}
EOF

rm /etc/nginx/sites-enabled/default
echo "$NGINXTEMPLATE" > /etc/nginx/sites-available/helpspot
ln -s /etc/nginx/sites-available/helpspot /etc/nginx/sites-enabled/helpspot
service nginx reload &> /dev/null

echo "Complete!"
