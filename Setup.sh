#!/bin/bash
read -p "Enter IP Address For Whitelisting: " IP

#sudo yum install denyhosts -y
#echo "sshd: $IP">>/etc/hosts.allow
#systemctl restart denyhosts

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo ':: Adding EPEL repo'
rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm || true

echo ':: Adding Ajenti repo'
rpm -ivh http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm

echo ':: Installing package'
yum install ajenti -y
yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql -y

echo ':: Done! Open https://<address>:8000 in browser'

firewall-cmd --permanent --zone=public --add-port=8000/tcp
firewall-cmd --reload

systemctl restart ajenti





