﻿#!/bin/bash
# CyberPatriot.sh Version 2

# exit out if we're not root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

list_all_services() {
    service --status-all | less -P ":q to exit"
}

set_update_settings() {
    # these are the recommended settings set in software-properties-gtk
    apt_config=/etc/apt/apt.conf.d/10periodic
    echo "APT::Periodic::Update-Package-Lists \"1\";" > $apt_config
    echo "APT::Periodic::Download-Upgradeable-Packages \"1\";" >> $apt_config
    echo "APT::Periodic::AutocleanInterval \"0\";" >> $apt_config
    echo "APT::Periodic::Unattended-Upgrade \"1\";" >> $apt_config
    echo "Set apt update settings"
}

disable_ssh_root_login() {
    if [[ -f /etc/ssh/sshd_config ]]; then
        sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
    else
        echo "No SSH server detected so nothing changed"
    fi
    echo "Disabled SSH root login"
}

find_media_files_in_dir() {
    mediaroot="/home/"
    mimes="image/\|video/\|audio/\|model/\|music/"
    pushd $mediaroot > /dev/null
    find -type f -print0 | xargs -0 file --mime-type | grep $mimes | less -P "Media Files"
    popd > /dev/null
}

enable_repositories() {
    echo "#deb cdrom:[Ubuntu 12.04.1 LTS _Precise Pangolin_ - Release i386 (20120817.3)]/ precise main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise main restricted
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise universe
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise universe
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
    deb http://us.archive.ubuntu.com/ubuntu/ precise multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise multiverse
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse
    deb http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
    deb http://security.ubuntu.com/ubuntu precise-security main restricted
    deb-src http://security.ubuntu.com/ubuntu precise-security main restricted
    deb http://security.ubuntu.com/ubuntu precise-security universe
    deb-src http://security.ubuntu.com/ubuntu precise-security universe
    deb http://security.ubuntu.com/ubuntu precise-security multiverse
    deb-src http://security.ubuntu.com/ubuntu precise-security multiverse
    # deb http://archive.canonical.com/ubuntu precise partner
    # deb-src http://archive.canonical.com/ubuntu precise partner
    deb http://extras.ubuntu.com/ubuntu precise main
    deb-src http://extras.ubuntu.com/ubuntu precise main" > /etc/apt/sources.list
    echo "created standard sources.list."
}

preserve_root_uid() {
    if [[ $(grep root /etc/passwd | wc -l) -gt 1 ]]; then
        grep root /etc/passwd | wc -l
    else
        echo "UID 0 is reserved to root"
    fi
}

remove_hacking_tools() {
    # Why not?
    apt-get autoremove --purge john netcat nmap hydra aircrack-ng
    echo "Hacking tools should be removed now"
}

check_no_pass() {
    sed -i s/NOPASSWD:// /etc/sudoers
    echo "Removed any instances of NOPASSWD in sudoers"
}

list_sensitive_groups() {
    echo "Members of group 'adm':"
    grep adm /etc/group | cut -d ':' -f 4
    echo "Members of group 'root':"
    grep root /etc/group | cut -d ':' -f 4
    echo "Members of group 'sudo':"
    grep sudo /etc/group | cut -d ':' -f 4
}

# change_user_passwords() {
#   u="$USER"
#   pass='CyberPatriot!'
#   echo "Changing all user passwords to $pass"
#   echo 'NEVER RUN THIS IN A PRODUCTION IMAGE!'
#    for i in $(ls /home); do # ls like a boss
         # globs be hatin on us
#        chpasswd <<< "$i:$pass"
#}

disable_Guest_Account() {
    echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
    echo "Disabled guest account."
}

setup_password_history() {
    echo "Setting up password history.."
    # making these seperate commands for readability's sake as well as mutability.
    sed -i.bak -e 's/PASS_MAX_DAYS\t[[:digit:]]\+/PASS_MAX_DAYS\t90/' /etc/login.defs
    sed -i -e 's/PASS_MIN_DAYS\t[[:digit:]]\+/PASS_MIN_DAYS\t10/' /etc/login.defs
    sed -i -e 's/PASS_WARN_AGE\t[[:digit:]]\+/PASS_WARN_AGE\t7/' /etc/login.defs
    echo "Max days set to: 90, Min days: 10, Warn age: 7."
}

disable_root_account() {
  passwd -l root
  echo "Locked root account."
}

install_software() {
    cd /
    echo "Installing firefox, hardinfo, chkrootkit, iptables, portsentry, lynis & ufw.."
    apt-get update
    apt-get upgrade
    apt-get -V -y install firefox, hardinfo, chkrootkit, iptables, portsentry, lynis, ufw
}

log_antivirus() {
    mkdir -v $HOME/.log-files
    echo "Logging info from antivirus & security tools"
    hardinfo -r -f html > /$HOME/Desktop/.logfiles/hardinfo-html.html
    chkrootkit > /$HOME/Desktop/.logfiles/chkrootkit.log
    checkps > /$HOME/Desktop/.logfiles/checkps.log
    lynis -c > /$HOME/Desktop/.logfiles/lynis.log
}

firewall_config() {
    echo "Firewall configuration.."
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP         #Block Telnet
    echo "Blocked Telnet!"
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
    echo "Blocked NFS!"
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
    echo "Blocked NFS!"
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
    echo "Blocked X-Windows!"
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
    echo "Blocked X-Windows font server!"
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
    echo "Blocked printer port!"
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
    echo "Blocked printer port!"
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
    echo "Blocked Sun RPC/NFS!"
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
    echo "Blocked Sun RPC/NFS!"
    iptables -A INPUT -p all -s localhost  -i eth0 -j DROP            #Deny outside packets from internet which claim to be from your loopback interface.
    echo "Blocked fake loopback packets!"
}

# Checking if you read the scenario
echo "# Ubuntu Security Scripts"
echo "# Make sure you READ THE SCENARIO"
echo "# R E A D  T H E  S C E N A R I O"
echo -n "# Did you read scenario? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
  echo "##### Configuring firewall #####"
  firewall_config

  echo "##### Installing security tools #####"
  install_software

  echo "##### Logging info from security tools #####"
  log_antivirus

  echo "##### Setting apt update settings #####"
  set_update_settings

  echo "##### Enabling default apt repositoriess #####"
  enable_repositories

  echo "##### Disabling SSH root login #####"
  disable_ssh_root_login

  echo "##### Making sure root is the only user with UID 0 #####"
  preserve_root_uid

  echo "##### Removing any 'hacking tools' from system #####"
  remove_hacking_tools

  echo "##### Listing all currently active services #####"
  echo "# to remove a serivce:"
  echo "# sudo apt-get -y autoremove --purge <package>"
  list_all_services

  echo "##### Removing any instances of NOPASSWD in /etc/sudoers #####"
  check_no_pass

  echo "##### Searching for any media files in /home #####"
  find_media_files_in_dir

  echo "##### Disabling the guest account #####"
  disable_Guest_Account

  read -p "Would you like to change all user passwords?" answer
  if [[ $answer == [yY] ]]; then
      change_user_passwords
  else
      echo "Not changing user passwords"
  fi

  read -p "Would you like to lock the root account?" answer
  if [[ $answer == [yY] ]]; then
      disable_root_account
  else
      echo "Not locking root account."
  fi

  echo "##### Listing users in sensitive groups #####"
  list_sensitive_groups

  echo "##### System secured #####"
  exit
else
    echo "READ THE SCENARIO"
    exit
fi
