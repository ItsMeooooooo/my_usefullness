#!/bin/bash
#
# Name		: promtcolors.sh (the typo is intended
#				  at least now)
# Provides      : Creates a bash Startup Environment
# Description   : Create a startup Environment, sets some
#		  Aliases and defines some usefull functions
# Location:	: /etc/profile.d/
#
# Modified      : 08|12|2020
# Author        : ItsMe
# Reply to      : itsme@bubbleclub.de           
#
# Comment:	: I did not test for POSIX Compliance
#		  Most of the time I work in RHEL/ CentOS
#		  Environments. Simply place the File
#		  in your /etc/profile.d and it should be
#		  parsed properly. You'll experience 
#		  a different Behavior on Debian based
#		  Distros. Here you have to edit
#		  /etc/profile and add:
#
# 		  if [ -d /etc/profile.d ]; then
#   			for i in /etc/profile.d/*.sh; do
#     				if [ -r $i ]; then
#       				.  $i
#     				fi
#   			done
#   			unset i
# 		  fi
#
#########################################################
# 
# OK - Lets Work
#
#########################################################


# .bashrc
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensty
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensty
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensty backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[10;95m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

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

alias ..='cd ..'
alias ...='cd ../..'
alias jeo='joe'
alias sun="su -c 'su -s $(command -v bash) - nginx'"
alias shred='shred -n 100 -z -v -u'
alias docker=podman

# ignore Dupes and Lines with whitespaces
# options are: ignorespace, ignoredups and ignoreboth
HISTCONTROL=ignoreboth

if [[ $EUID -eq 0 ]];
	then
	# if root set prompt to red
		PS1="\[$bldred\][\u\[$bldwht\]@\[$bldred\]\h\[$bldylw\] \W\[$bldred\]]\[$bldylw\]\$\[$txtrst\] "; 
	# if nginx another color and go to '/var/www/html
	elif [[ $EUID -eq $(grep nginx /etc/passwd | grep -Eo '[0-9]{1,}' | head -n1) ]];
		then 
		PS1="\[$bldgrn\][\u\[$bldwht\]@\[$bldgrn\]\h\[$bldylw\] \W\[$bldgrn\]]\[$bldylw\]\$\[$txtrst\] ";
		cd /var/www/html/
	# colors for standard user(s)
	else
		PS1="\[$bldblu\][\u\[$bldwht\]@\[$bldblu\]\h\[$bldylw\] \W\[$bldblu\]]\[$bldylw\]\$\[$txtrst\] ";
fi

# export joe as default editor
#
# since my first Distro was a slackware and back in the Day
# the only Editor I've found as a rookie was 'joe' I'm still
# stuck with it
if type joe > /dev/null; then
    export EDITOR=/usr/bin/joe
fi

# some Functions
function generate_ssl_cert {
  cert_name=$1

  (
        openssl genrsa -des3 -out ${cert_name}.key 1024
        openssl rsa -in ${cert_name}.key -out ${cert_name}.pem
        openssl req -new -key ${cert_name}.pem -out ${cert_name}.csr
        openssl x509 -req -days 365 -in ${cert_name}.csr -signkey ${cert_name}.pem -out ${cert_name}.crt
  )
}


cd() {
  if [ -n "$1" ]; then
    builtin cd "$@" && ls --group-directories-first
  else
    builtin cd ~ && ls --group-directories-first
  fi
}

function myip(){
    curl -s http://checkip.dyndns.org:8245 | grep -Eo '[0-9.]{7,15}'
}

function check_(){
	cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30
}

function compress_() {
   # Credit goes to: Daenyth
   FILE=$1
   shift
   case $FILE in
      *.tar.bz2) tar cjf $FILE $*  ;;
      *.tar.gz)  tar czf $FILE $*  ;;
      *.tgz)     tar czf $FILE $*  ;;
      *.zip)     zip $FILE $*      ;;
      *.rar)     rar $FILE $*      ;;
      *)         echo "Filetype not recognized" ;;
   esac
}

extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}
function serve (){
	echo "Serving the Directory on Port 8000"
	if ! type python3 > /dev/null; then 
	    python -m SimpleHTTPServer 8000
	else
	    python -m http.server 8000
	fi
}

# EOF
