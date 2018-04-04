#!/bin/bash
#this script is used to check open and syn ports
#created in March 7, 2018
if [ $UID != 0 ];
	then
	echo "this script must be run as  root" 
	exit
fi

clear

echo "installing NMAP"

apt-get install nmap

clear

echo "running a port scan and syn scan"

nmap -v -sT localhost > ~/openports.txt && nmap -v -sS localhost >> ~/openports.txt

clear
echo -e "do you want to open the log file [y/n]"
read -p "->" continue

if [ $continue == "n"];
	then
		echo "opening the log file"
		exit
fi

clear

vim ~/openports.txt
