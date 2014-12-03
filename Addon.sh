#!/bin/bash

yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql -y

systemctl restart ajenti
