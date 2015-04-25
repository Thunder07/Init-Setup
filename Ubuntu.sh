#!/bin/sh

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   sudo $0
   exit
fi

sudo apt-add-repository -y ppa:paolorotolo/android-studio
sudo apt-get -y update
sudo apt-get -y install bison build-essential curl flex git gnupg gperf libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-6-jdk openjdk-6-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt-get -y install g++-multilib gcc-multilib lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev
sudo apt-get install libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1
sudo apt-get -y install git wget hexchat html-xml-utils html2text
sudo apt-get -y install p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller
sudo apt-get -y install unity-tweak-tool gnome-tweak-tool
sudo apt-get -y install android-tools-adb android-tools-fastboot
sudo apt-get -y install android-studio

exit
git clone https://github.com/Thunder07/apk2gold.git
cd apk2gold
./make.sh
cd ..


exit
mkdir -p ~/bin
PATH="$HOME/bin:$PATH"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

droid_root="~/android/omni"
mkdir -p ~/$droid_root
cd $droid_root
repo init -u https://github.com/marduk191/recovery_manifest.git

cd $droid_root
rm -Rf ./bootable/recovery
git clone https://github.com/Thunder07/Team-Win-Recovery-Project.git bootable/recovery

cd ./bootable/recovery/
git remote add Tas https://github.com/Tasssadar/Team-Win-Recovery-Project.git


cd $droid_root
git clone https://github.com/Thunder07/AROMA-Filemanager.git bootable/recovery/aromafm
git clone https://github.com/Thunder07/multirom.git system/extras/multirom
git clone https://github.com/Tasssadar/libbootimg.git system/extras/libbootimg

cd system/extras/multirom
git remote add Tas https://github.com/Tasssadar/multirom.git
git submodule update --init
