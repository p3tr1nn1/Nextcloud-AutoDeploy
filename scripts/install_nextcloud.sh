#!/bin/bash
sudo apt-get update -qq
#sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -qq -y
sudo apt-get install unzip apache2 mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip -y
cd /tmp
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
sudo cp -r nextcloud /var/www/html
sudo mkdir /var/www/html/nextcloud/data
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/OU=YourOrganizationalUnit/CN=YourServerNameOrIP/emailAddress=youremail@example.com"
sudo cp /tmp/autoconfig.php /var/www/html/nextcloud/config/autoconfig.php
sudo cp /tmp/nextcloud-ssl.conf /etc/apache2/sites-enabled/nextcloud-ssl.conf
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo a2ensite nextcloud.conf
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime
sudo a2enmod ssl
sudo a2ensite nextcloud-ssl.conf
sudo systemctl reload apache2
sudo systemctl enable apache2
