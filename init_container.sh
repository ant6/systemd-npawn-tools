#!/bin/bash

print_ok='[  OK  ] '
print_err='[ERROR] '

# get container desired location
if [ -d $1 ]
then
	container_location=$1
	echo "Container location set to: " $1
else
	# default location
	container_location="/srv/mycontainer"
fi

# Gathering system info 

# check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo $print_err "Sorry, you are not root."
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

	yum -y --releasever=20 --nogpg --installroot=$container_location --disablerepo='*' --enablerepo=fedora install systemd passwd yum fedora-release vim-minimal nano

	if [ $(echo $?) == 0 ]
	then
		echo $print_ok "Great success - Fedora minimal created!"
		echo "         Entering container!"
		# copy change passwd script and execute it
		cp set_root_passwd.sh $container_location/root/
		# chmod 777 $container_location/root/set_root_passwd.sh
		systemd-nspawn -D $container_location ./root/set_root_passwd.sh
			if [ $(echo $?) == 0 ]
			then
				echo $print_ok "Great success - password changed!"
			fi
		# "boot" the conainer
		systemd-nspawn -bD $container_location
	fi

#elif [[ $os == *"Arch"* ]]
else
	echo $print_err "Not yet implemented"
fi
