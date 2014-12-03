#!/bin/bash

yum install wget -y
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y

yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql -y
firewall-cmd --permanent --zone=public --add-port=80/tcp
systemctl restart ajenti
