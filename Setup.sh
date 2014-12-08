#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

IP=`who am i | awk '{print $5}' | sed 's/[()]//g'`
ttypts=`who am i | awk '{print $2}' | sed 's|\/[1-9]||g'`

if [ "$ttypts" != "pts"]; then
   IP="127.0.0.1"
   echo "we've detected that you're not connected through SSH"
   echo "Thus for whitelisting we will assume your IP is 127.0.0.1"
   
   read -p "Continue(y) or Enter a new IP(n)??[y/n]" ans1
   if [ $ans1 == "n" ]; then
      clear
      read -p "Please Enter IP:" IP
   elif [ $ans1 == "y" ]; then
      clear
      echo "Quitting"
      return 0 2> /dev/null || exit 0
   else
      clear
      echo "Answer Unclear Quitting"
      return 0 2> /dev/null || exit 0
   if

fi


echo "This script was made to be used with Centos7/RH7"
echo "This automated script will install & setup:"
echo "Ajenti(+V Addons), Denyhosts, EPEL repo, mysql & Knock"
echo "While also configurating ports assoicated with them"



echo "Your IP ($IP) will be whitelisted from denyhosts and granted access to ssh through the firewall."

read -p "Do you want to start??[y/n]" ans2
if [ $ans2 == "y" ] ; then
echo "Starting....."
else
echo "Quitting"
return 0 2> /dev/null || exit 0
if

rpm -Uvh http://mirror-fpt-telecom.fpt.net/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/denyhosts-2.6-5.el7.rf.noarch.rpm
cp /etc/hosts.allow hosts.allow.bak
echo "sshd: $IP">>/etc/hosts.allow
systemctl restart denyhosts

echo ':: Adding EPEL repo'
rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm || true

echo ':: Adding Ajenti repo'
rpm -ivh http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm

rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y

echo ':: Installing Ajenti package'
yum install ajenti -y
yum install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql ajenti-v-ftp-pureftpd -y

systemctl restart pure-ftpd
sleep 5
cp /var/lib/ajenti/plugins/vh-pureftpd/pureftpd.py pureftpd.py.bak
cd /var/lib/ajenti/plugins/vh-pureftpd/
cat pureftpd.py | sed -e 's|clf:/var/log/pureftpd.log|clf:/var/log/pureftpd.log\nPassivePortRange            40110 40510\nTLS                         2\nTLSCipherSuite              HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3|g'>pureftpd.py.new
cat  pureftpd.py.new>pureftpd.py
rm pureftpd.py.new -f
python -m pureftpd.py
cd ~

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


#For security, changing sshd port
#You should manually disable ssh root login and create a 2nd root usr
echo "Securing Root Access, Disabling Remote Root For Security, changing ssh port."
echo "If You Use SSH, Please Create A 2nd SU before proceeding."
read -p "Do you want to continue??[y/n]" ans
if [ $ans == "y" ] ; then
      cp /etc/ssh/sshd_config sshd_config.bak
      firewall-cmd --permanent --zone=public --add-port=2123/tcp
      echo "PermitRootLogin no">>/etc/ssh/sshd_config
      echo "Protocol 2">>/etc/ssh/sshd_config
      echo "Port 2123">>/etc/ssh/sshd_config
else
      echo "Skipping"
fi

#Extras
yum install wget -y
echo "Downloading, Building, Updating & Setting up Knock"
#Knock is not avalible for Centos7, Thus we must build it then update it.
yum install rpm-build redhat-rpm-config make gcc -y
wget http://www.invoca.ch/pub/packages/knock/RPMS/ils-5/SRPMS/knock-0.5-7.el5.src.rpm
rpmbuild --rebuild knock-0.5-7.el5.src.rpm
wget https://github.com/jvinet/knock/archive/master.zip
unzip master.zip
cd knock-master
autoreconf -fi
./configure --prefix=/usr/local
make
make install
systemctl stop knockd
/bin/cp -f knockd /usr/sbin/knockd
/bin/cp -f knock /usr/local/bin/knock
cd ..

cp /etc/knockd.conf knockd.conf.bak
sed 's|/usr/sbin/iptables -A INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT|/usr/bin/firewall-cmd --zone=public --add-rich-rule="rule family="ipv4" source address="%IP%" port protocol="tcp" port="22" accept"|' /etc/knockd.conf >/etc/knockd.conf.1
sed 's|/usr/sbin/iptables -D INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT|/usr/bin/firewall-cmd --zone=public --remove-rich-rule="rule family="ipv4" source address="%IP%" port protocol="tcp" port="22" accept"|' /etc/knockd.conf.1 >/etc/knockd.conf.2
sed 's/syn,ack/syn/' /etc/knockd.conf.2 >/etc/knockd.conf
rm -f /etc/knockd.conf.*

firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --remove-port=22/tcp
firewall-cmd --reload

echo "Yum Update"
yum update -y
