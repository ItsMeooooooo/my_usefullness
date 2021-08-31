#!/usr/bin/env bash
#
# Provides      : Transfer (Backup) ZFS Pool(s)
# Description   : A short script to sync ZFS Snapshots between
#                 volumes. It mounts a predefined Backup Pool 
#                 and syncs the production Pool(s) to it.
#                 Its Main purpose is to transfer ZFS Pools to an external HDD.
#            
# TODO          : a) Implement simple logging capabilities
#                 b) Implement a proper Errorhandling
#                 c) Implement commandline options
#                 d) Implement capacity check
#
# Created       : 10|02|2019
#
# Author        : ItsMe
# Reply to      : itsme@bubbleclub.de
#
# Licence       : MIT Licence
#
# Editor(s)     : joe
#########################################################
#
# OK - Lets Work
#

# set some variables

set -o errexit                                                  # equivalent to: "set -e" (make the script execution terminate)
set -o nounset                                                  # equivalent to: "set -u" (terminate the script when a variable isn't set)
set -o pipefail                                                 # make the whole pipe fail when a subcommand fails

# define some colors
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
txtrst='\e[0m'    # Text Reset

txt_wrong=$bldred'[-]'$txtrst
txt_ok=$bldgrn'[+]'$txtrst
txt_info=$bldgrn'[Info]'$txtrst

AWK=$(command -v awk)                       
HEAD=$(command -v head)                     
GREP=$(command -v grep)                       
ZPOOL=$(command -v zpool)                   
SYNCOID=$(command -v syncoid)

TARGET="extBackup"
PRODUCTION=()

function do_sync(){
        for i in "${!PRODUCTION[@]}"; do
                echo -e "$txt_info Transfering: $bldred${PRODUCTION[$i]}$txtrst"
                "$SYNCOID" -r "${PRODUCTION[$i]}" $TARGET/"${PRODUCTION[$i]}"
        done
        $ZPOOL export $TARGET                                   # export the Pool
}

function do_checks() {
        echo -e "$txt_ok Checking for Production Pools"
        TMP="$(zpool status | $GREP pool: | $AWK '{ print $2 }')"
        for i in $TMP; do
                echo -e "$txt_info Found Pool: $bldred $i"
                PRODUCTION+=("$i")
        done
        echo -e "$txt_ok Checking for Backup Pools"
	found_pool="$($ZPOOL import | $HEAD -n 1 | $AWK '{ print $2 }')"
        if [ "$TARGET" = "$found_pool" ]; then
                echo -e "$txt_info importing Pool: $bldred$TARGET"
                $ZPOOL import $TARGET
                echo -e "$txt_info Done"
                do_sync
        else
                echo -e "$txt_wrong No sufficient Target Pool found"
        fi
}

if [[ $EUID -ne 0 ]]; then
	echo -e "$txt_wrong Insufficient Privileges - You have to be root to run this script\n$txt_wrong Consider the use of sudo\n$txt_wrong Exiting..."
	exit 1
else
        do_checks
fi


# EOF
