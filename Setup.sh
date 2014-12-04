#!/bin/bash
read -p "Enter IP Address For Whitelisting: " IP

rpm -Uvhi rpm -Uvh --oldpackage http://mirror-fpt-telecom.fpt.net/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/denyhosts-2.6-5.el7.rf.noarch.rpm
echo "sshd: $IP">>/etc/hosts.allow
systemctl restart denyhosts

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo ':: Adding EPEL repo'
rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm || true

echo ':: Adding Ajenti repo'
rpm -ivh http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm

rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y

echo ':: Installing package'
yum install ajenti -y
yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql ajenti-v-ftp-pureftpd -y

#systemctl restart pure-ftpd
#sleep 5

#useless at the moment, Ajenti overwrites setting after each update
#echo "PassivePortRange           40110 40510" >> /etc/pure-ftpd/pure-ftpd.conf
#echo "TLS           2" >> /etc/pure-ftpd/pure-ftpd.conf
#echo "TLSCipherSuite           HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3" >> /etc/pure-ftpd/pure-ftpd.conf

firewall-cmd --permanent --zone=public --add-port=21/tcp
firewall-cmd --permanent --zone=public --add-service=ftp
firewall-cmd --permanent --zone=public --add-port=40110-40510/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-port=8000/tcp
firewall-cmd --reload

echo ':: Done! Open https://<address>:8000 in browser'


systemctl restart pure-ftpd
systemctl restart ajenti

#Extras
yum install wget -y



