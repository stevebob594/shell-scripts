#!/bin/bash

#Makes script only executable by root
if [ $EUID -ne 0 ]; then
	echo "Err. NOT ROOT"
	exit
fi

echo "Script Starting: "

sudo apt-get update && sudo apt-get upgrade

#Dependencies for the script
sudo apt-get install clamav
sudo apt-get install nmap
sudo apt-get install ufw

echo "Installed dependencies and updated using apt-get.\n"

sudo ufw enable 

echo "Firewall enabled, no ports are currently blocked."

sudo passwd -l root

echo "Root has been locked, change the password? [Y/n]"
read chgrootpasswd
if [ $chgrootpasswd == "Y" ] || [ $chgrootpasswd == "y" ] || [ $chgrootpasswd =="" ]; then

	echo "What should the root passwd be? "
	read newpasswd 
	
	echo "$newpasswd" > sudo passwd root
	echo "Root has been locked and passwd changed.\n"

elif [ $chgrootpasswd == "N" ] || [ $chgrootpasswd "n" ]; then 
	continue
fi

echo "Do you want to store information on the system? [Y/n]"
read storeInfo

if [ $storeInfo == "Y" ] || [ $storeInfo == "y" ] || [ $storeInfo == "" ]; then

	#Creates system info files
	mkdir ~/CyberPatSysInfo
	ps -ax > ~/CyberPatSysInfo/services.txt
	ls -l /etc/rc.d/rc5.d/S* > ~/CyberPatSysInfo/startupServ.txt

	echo "Files have been created and stored in ~/CyberPatSysInfo."

elif [ $storeInfo == "N" ] || [ $storeInfo == "n" ]; then 
	continue
fi

echo "Checking file permissions"

if [ stat -c "%a %n" /etc/fstab -ne 644 ]; then 
	echo "Check /etc/fstab"
fi

if [ stat -c "%a %n" /etc/passwd -ne 644 ]; then 
	echo "Check /etc/passwd"
fi

if [ stat -c "%a %n" /etc/group -ne 644 ]; then 
	echo "Check /etc/group"
fi 

if [ stat -c "%a %n" /etc/shadow -ne 400 ]; then 
	echo "Check /etc/shadow"
fi 

echo "Done checking file permissions"

echo "Enter the login.defs.bak file path"
read loginDefsPath

echo "Ensure logins.defs.bak is the configuration you would like\nAlso that you remove .bak"

rm /etc/login.defs
sudo cat "$loginDefsPath" > /etc/login.defs

echo "Changing CRON information"

sudo rm -f /etc/con.deny /etc/at.deny
sudo echo root > /etc/cron.allow
sudo echo root > /etc/at.allow
sudo chown root:root /etc/cron.allow /etc/at.allow
sudo chmod 400 /etc/cron.allow /etc/at.allow

echo "CRON information is updated."

echo "Checking for prohibited media files"

sudo find / -name *.jpg
sudo find / -name *.jpeg
sudo find / -name *.png
sudo find / -name *.bmp
