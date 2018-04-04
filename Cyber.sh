#!/bin/bash 
#This script takes the first round of cyber patriot and automates it
#Created November 4th 
clear

if [ $UID != 0 ]; 
	then 
		echo "You must be root to run this script."
		exit
fi

echo -e "Please read the scenario before you continue\nDo you want to continue? [y/n]"
read -p "-> " continue 

if [ $continue == "n" ]; 
	then 
		echo "Stopping Script."
		exit
fi 

clear
echo -e "Script Starting.\n\n"
echo "Updating System"

sudo apt-get update > /dev/null
sudo apt-get upgrade > /dev/null

echo -e "Finished Updating System"

echo "Searching For Media Files"
find /home -name *.mp4
find /home -name *.mp3
find /home -name *.mpg
find /home -name *.wav
find /home -name *.wma
find /home -name *.aiff
find /home -name *.bvf
find /home -name *.m3u
find /home -name *.dat
find /home -name *.pls
find /home -name *.avi 
find /home -name *.asf
find /home -name *.mov
find /home -name *.qt
find /home -name *.avchd
find /home -name *.flv
find /home -name *.swf
find /home -name *.jpeg
find /home -name *.jpg
find /home -name *.tiff
find /home -name *.bmp
find /home -name *.rif
find /home -name *.psd
find /home -name *.xcf
find /home -name *.ai
find /home -name *.cdr
find /home -name *.tiff
find /home -name *.gif
find /home -name *.png
find /home -name *.eps
find /home -name *.raw
find /home -name *.cr2
find /home -name *.net
find /home -name *.orf
find /home -name *.sr2

echo -e "\nFinished Searching For Media Files\n"

apt-get install nmap > /dev/null
apt-get install ufw > /dev/null

ufw enable > /dev/null

echo -e "\nFirewall Enabled\nStarting Nmap"

nmap -p1-65535 -sT --min-rate 5000 127.0.0.1 | grep "tcp"
nmap -p1-65535 -sU --min-rate 5000 127.0.0.1 | grep "udp"

echo -e "Finished Nmap Scans\nLocking Root"

passwd -l root

echo -e "\nRoot account locked\nDeactivating Guest Account"
echo "Does a config already exist for Guest? [y/n]"
read guestConfig
if [ $guestConfig == "y" ]; 
	then
		echo "Please configure the file yourself"
elif [ $guestConfig == "n" ]; 
	then 
		cd /etc/lightdm
		mkdir lightdm.conf.d
		touch lightdm.conf.d/50-my-custom.conf
		echo -e "[SeatDefaults]\nallow-guest=false" > lightdm.conf.d/50-my-custom.conf
		#reboot needed 
fi 

echo "This script needs to reboot the system, please give permission [y/n]"
read permission 
if [ $permission == "y" ]; 
	then 
		echo "rebooting"
		reboot
elif [ $permission == "n" ];
	then 
		echo "Please make sure you manually reboot the system"
fi
