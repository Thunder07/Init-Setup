#!/bin/bash



yum install ajenti-v-ftp-pureftpd -y

echo "PassivePortRange           40110 40510" >> /etc/pure-ftpd/pure-ftpd.conf
echo "TLS           2" >> /etc/pure-ftpd/pure-ftpd.conf
echo "TLSCipherSuite           HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3" >> /etc/pure-ftpd/pure-ftpd.conf
firewall-cmd --permanent --zone=public --add-port=40110-40510/tcp

systemctl restart ajenti
