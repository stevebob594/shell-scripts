#!/bin/bash

homeDIRS=$(ls /home)

echo "Mac or UNIX?"
read os

if [ $os == "UNIX" ]; then

	echo -e "UNIX Selected. \nGrabbing Crontabs..."

	if [ $EUID -ne 0 ]; then
		echo "You must be root to run this script."
		exit
	else
		continue
	fi

	for dir in $homeDIRS
	do

		#This could be better, eh, Squads and Spotify seems nice. L8r.
		echo -e "##### CRON FOR $dir ##### \n"
		crontab -u $dir -l
		echo -e "\n######################### \n"

	done

elif [ $os == "Mac" ]; then
	
	#Jordan finish this soon for Cyber, lazy...
	#Actually its MAC who gaf, go play fortnite fgt
	echo -e "Mac Selected. \nGrabbing Crontabs..."

fi
