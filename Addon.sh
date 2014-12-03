#!/bin/bash

wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server


yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql -y

systemctl restart ajenti
