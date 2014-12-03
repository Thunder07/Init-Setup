#!/bin/bash



yum install ajenti-v-ftp-pureftpd -y

systemctl restart pure-ftpd
sleep 5
echo "PassivePortRange           40110 40510" >> /etc/pure-ftpd/pure-ftpd.conf
echo "TLS           2" >> /etc/pure-ftpd/pure-ftpd.conf
echo "TLSCipherSuite           HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3" >> /etc/pure-ftpd/pure-ftpd.conf

firewall-cmd --permanent --zone=public --add-service=ftp
firewall-cmd --permanent --zone=public --add-port=40110-40510/tcp
firewall-cmd --permanent --zone=public --add-port=21/tcp

systemctl restart pure-ftpd
systemctl restart ajenti
