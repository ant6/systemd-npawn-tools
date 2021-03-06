#!/bin/bash

# this script generates necessary elements, such as containers
# and sets them up with systemd-nspawn

print_ok='[\e[1;32m  OK  \e[0m] '
print_err='[\e[1;31mERROR\e[0m] '

# get container desired location
if [ -d $1 ] && [ "$1" != "" ]
then
	container_location=$1
	echo -e $print_ok "Container location set to: " $1
elif [ "$1" == "" ]
then
	# default location
	container_location="/srv/mycontainer"
	echo -e $print_ok "Container location set to: " $container_location
else
	echo -e $print_err "Wrong container location!"
	echo "use: $0 <container location>"
	exit 37
fi

# Gathering system info 

# check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo -e $print_err "Sorry, you are not root."
	exit 1
fi

arch=$(uname -m)
kernel=$(uname -r)
if [ -f /etc/lsb-release ]; then
        os=$(lsb_release -s -d)
elif [ -f /etc/debian_version ]; then
        os="Debian $(cat /etc/debian_version)"
elif [ -f /etc/redhat-release ]; then
        os=`cat /etc/redhat-release`
else
        os="$(uname -s) $(uname -r)"
fi

# Printing system info 

echo "Detected:" $os
echo "         " $arch
echo "         " $kernel
echo "-------------------------------"

# Creating container for Fedora
if [[ $os == *"Fedora"* ]]
then

	echo "         Creating a Fedora container tree in a subdirectory"

	dnf -y --releasever=20 --nogpg --installroot=$container_location --disablerepo='*' --enablerepo=fedora install systemd passwd yum fedora-release vim-minimal nano

	if [ $(echo $?) == 0 ]
	then
		echo -e $print_ok "Great success - Fedora minimal created!"
		echo "         Entering container!"
		# copy change passwd script and execute it
		cp ../data/set_root_passwd.sh $container_location/root/
		chmod 777 $container_location/root/set_root_passwd.sh
		setenforce 0
		systemd-nspawn -D $container_location ./root/set_root_passwd.sh
			if [ $(echo $?) == 0 ]
			then
				echo -e $print_ok "Great success - password changed!"
			fi
		setenforce 1	
		rm $container_location/root/set_root_passwd.sh
	fi

#elif [[ $os == *"Arch"* ]]
else
	echo -e $print_err "Not yet implemented"
fi
