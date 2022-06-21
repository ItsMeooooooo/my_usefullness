#!/usr/bin/env bash
#
# Name          : promtcolors.sh (the typo is intended
#                                 at least now)
# Provides      : Creates a bash Startup Environment
# Description   : Create a startup Environment, sets some
#                 Aliases and defines some usefull functions
# Location:     : /etc/profile.d/
#
# Modified      : 08|12|2020
# Author        : ItsMe
# Reply to      : itsme@bubbleclub.de           
#
# Comment:      : I did not test for POSIX Compliance
#                 Most of the time I work in RHEL/ CentOS
#                 Environments. Simply place the File
#                 in your /etc/profile.d and it should be
#                 parsed properly. You'll experience 
#                 a different Behavior on Debian based
#                 Distros. Here you have to edit
#                 /etc/profile and add:
#
#                 if [ -d /etc/profile.d ]; then
#                       for i in /etc/profile.d/*.sh; do
#                               if [ -r $i ]; then
#                                       .  $i
#                               fi
#                       done
#                       unset i
#                 fi
#
#########################################################
# 
# OK - Lets Work
#
#########################################################


txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

txt_wrong=$bldred'[-]'$txtrst
txt_ok=$bldgrn'[+]'$txtrst
txt_info=$bldgrn'[Info]'$txtrst

function txt_green(){
	echo -ne $bldgrn$1$txtrst
}
function txt_red(){
	echo -ne $bldred$1$txtrst
}
function txt_bld(){
	echo -ne $bldwht$1$txtrst
}

needed_files=""
zfs_install_file="https://zfsonlinux.org/fedora/zfs-release$(rpm -E %dist).noarch.rpm"

standard_user=akrusch

ssh_port=2266

release_file=/etc/os-release

authorized_keys="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpSHQ/WxbZa9qYp651csBLXeCrTJdxibgStMdXo3wbyLjaFySG6AagJyVN84K8h/jIBYsUaHDH8BxzjpV6T32X6usy9xqhY4i7Q9FUQPc7VZzRuaZJXue2UX7DQAQFb6Pkuh89XEiJLGmzljex/d98xPC+d/czPdXNWurFoQts8ghUuLD2YglpP2qM4UdFUtkh1PCEy1jyLSajP2we4yEE5udPMNNKSKcTGYnZqzLpQ8ZcwyFzAIbVYd/e6A34j5zn6BCPBPSTUoU+wXzwfb8Yg7u7HwOFhX6u6VH7dlswEmcaJ4NYYX5TL56/xLIqRYiJUYTj3Rja56aICcNPxwnB krusch@rechner02-fe13.bubbleclub.de"
zfs_inst

if [ $? -eq "1" ] ; then                           
    echo -e "$txt_wrong dnf not found\naborting..."
    exit                                        
fi                                              

install_dir="/root/install/base"
urls="https://www.bubbleclub.de/gmyfiles/needed_files.tar.gz
http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
https://raw.githubusercontent.com/ItsMeooooooo/promtcolors/master/promtcolors.sh"

if [[ $EUID -ne 0 ]]; then
	echo -e "$txt_wrong Insufficient Privileges - You have to be root to run this script\n$txt_wrong Consider the use of sudo\n$txt_wrong Exiting...
			"
	exit 1
else
	mkdir -p $install_dir ; cd $install_dir
fi


is_inst_command="list installed"
inst_command="install"

OS=$(grep -w NAME /etc/os-release | cut -d"\"" -f2 | cut -d"=" -f2 | cut -d" " -f1 )
OSV=$(grep -w VERSION /etc/os-release | cut -d"\"" -f2 | cut -d"=" -f2 | cut -d" " -f1)
POS=$(grep -w PRETTY_NAME /etc/os-release | cut -d"\"" -f2 | cut -d"=" -f2)

readonly program_check="command -v"

BASH=$($program_check bash)

DNF=$($program_check dnf)

CURL=$($program_check curl)

function do_finish(){
	echo -e "$txt_ok Starting finishing Jobs"
	echo -e "$txt_ok Testing for standard user $bldwht$standard_user$txtrst"
	standard_user_exists=$(id $standard_user &>/dev/null)
	if [ $? -eq "1" ] ; then                           
    	echo -e "$txt_wrong user $bldwht$standard_user$txtrst not found\n$txt_ok adding user $bldwht$standard_user$txtrst"
		useradd -m -s $BASH -G wheel $standard_user
		echo -e $txt_ok added user $bldwht$standard_user$txtrst successfully
		echo -e $txt_ok creating basic folders and files
		mkdir -p /home/$standard_user/.ssh &>/dev/null
		touch /home/$standard_user/.ssh/authorized_keys
		echo -e "$authorized_keys > /home/$standard_user/.ssh/authorized_keys" &>/dev/null
		echo -e "if [ -f `which powerline-daemon` ]; then\npowerline-daemon -q\nPOWERLINE_BASH_CONTINUATION=1\nPOWERLINE_BASH_SELECT=1\. /usr/share/powerline/bash/powerline.sh\nfi\n" >> /home/$standard_user/.bashrc
		echo -e "if [ -f `which powerline-daemon` ]; then\npowerline-daemon -q\nPOWERLINE_BASH_CONTINUATION=1\nPOWERLINE_BASH_SELECT=1\. /usr/share/powerline/bash/powerline.sh\nfi\n" >> /root/.bashrc
		chown -R $standard_user: /home/$standard_user/.ssh
		chmod 0700 /home/$standard_user/.ssh &>/dev/null
		chmod 0600 /home/$standard_user/.ssh/authorized_keys &>/dev/null
		restorecon -Rv /home/$standard_user/ &>/dev/null
	else
		echo -e "$txt_ok standard user: $bldwht$standard_user$txtrst found"
	fi
	mv $install_dir/promtcolors.sh /etc/profile.d/promtcolors.sh &>/dev/null
	restorecon -Rv /home/$standard_user &>/dev/null
	restorecon -Rv /etc/profile.d &>/dev/null
}

function do_downloads(){
	for i in $urls
	do
#		chk_uri=$($CURL -Is $i | $grep 200 | cut -d" " -f2)
		echo -e "$txt_ok Downloading $i"
		$CURL --anyauth --user ItsMe:gmyfiles-entry -s -o $install_dir/${i##*/} $i
		if [[ $i = *bubbleclub* ]]; then
			needed_files=${i##*/}
		fi
		if [[ $i = *zfs* ]]; then
			zfs_install_file=${i##*/}
		fi
		
	done
	do_finish
}

# got this from:
# https://mike632t.wordpress.com/2017/07/06/bash-yes-no-prompt/
function yes_no(){
  local _prompt _default _response
 
  if [ "$1" ]; then _prompt="$1"; else _prompt="Continue..."; fi
  _prompt="$_prompt [y/n] ?"
 
  # Loop forever until the user enters a valid response (Y/N or Yes/No).
  while true; do
    read -r -p "$_prompt " _response
    case "$_response" in
      [Yy][Ee][Ss]|[Yy]|[Zz]) # Yes or Y or Z(case-insensitive).
        #return 0
		install_missing_progs
        ;;
      [Nn][Oo]|[Nn])  # No or N.
        return 1
        ;;
      *) # Anything else (including a blank) is invalid.
        ;;
    esac
  done
}

function install_missing_progs(){
	echo -e "$DNF $inst_command ${progs_to_install[@]} -y"
	echo -e "$txt_ok Downloading base files"
	do_downloads
	menu
}

function check_installed_programs() {
	echo -e "$txt_ok Testing for base programs"
	sleep 0.5
	for i in "${!basic_progs[@]}"; do
		if [ $($program_check ${basic_progs[$i]}) ]; then
			echo -e $txt_ok found: ${basic_progs[$i]} in $($program_check ${basic_progs[$i]})
			unset basic_progs[$i]
		else
			echo -e $txt_wrong missing: ${basic_progs[$i]}
			progs_to_install+=(${basic_progs[$i]})
		fi
	done
	for i in "${!selection_progs[@]}"; do
		#echo -e "${selection_progs[$i]}"
		$DNF "$is_inst_command" "${selection_progs[$i]}" &>/dev/null
		if [ $? -eq 1 ]; then
			echo -e $txt_wrong missing: ${selection_progs[$i]}
			progs_to_install+=(${selection_progs[$i]})
		else
			echo -e $txt_ok found: ${selection_progs[$i]}
		fi
	done
	echo -e "\nInstalling: $bldred${progs_to_install[@]}$txtrst"
	yes_no
	#exit 0
}

function set_vars(){
	case $1 in

		basic_system)
			echo -en "$txt_ok Installing Basic System\n"
			basic_progs=(uname curl grep cut dnf yum tar wget sed awk
						modprobe tmux joe powerline lolcat iotop)
			selection_progs=(podman buildah udica setroubleshoot-server
							cockpit cockpit-machines cockpit-podman)
			urls="https://raw.githubusercontent.com/ItsMeooooooo/promtcolors/master/promtcolors.sh"
			check_installed_programs
			;;

		virt_host)
			echo -en "$txt_ok Installing Virtualisation Host\n"
			basic_progs=(uname curl grep cut dnf yum tar wget sed awk
							modprobe tmux joe lolcat)
			selection_progs=(podman buildah udica setroubleshoot-server
							qemu-kvm libvirt virt-install bridge-utils
							libguestfs-tools libguestfs-xfs virt-top
							cockpit cockpit-machines cockpit-podman
							zfs)
			urls="https://raw.githubusercontent.com/ItsMeooooooo/promtcolors/master/promtcolors.sh"
			check_installed_programs
			;;		
		*)
			echo -en "Unknown Installation"
			;;
	esac	
	
}
echo -e	""
echo -e "$txt_ok OS: $OS"
echo -e "$txt_ok Version: $OSV"
echo -e "$txt_ok Pretty Name: $POS\n"
sleep 0.5

function menu(){
	progs_to_install=()
	echo -ne "
				$(txt_bld 'Select Installation Method')
$(txt_green '1)') Install Basic System
$(txt_green '2)') Install Virtualisation Host
$(txt_red '0)') Exit
$(txt_green 'Choose an option:') "
        read -r a
        case $a in
	        1) set_vars basic_system; menu ;;
	        2) set_vars virt_host; menu ;;
		0) exit 0 ;;
		*) echo -e $bldred"Wrong option."$txtrst; menu;;
        esac
}

# Call the menu function
menu

# EOF