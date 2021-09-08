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
#
# Created       : 10|02|2019
# Version       : 0.1
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
bldred='\e[1;31m'                                               # Red
bldgrn='\e[1;32m'                                               # Green
bldblu='\e[1;34m'                                               # Blue
txtrst='\e[0m'                                                  # Text Reset

txt_wrong=$bldred'[-]'$txtrst                                   # [-]
txt_ok=$bldgrn'[+]'$txtrst                                      # [+]
txt_info=$bldgrn'[Info]'$txtrst                                 # [Info]

AWK=$(command -v awk)                                           # check for aviable utils
HEAD=$(command -v head)                                         # all of them should be
GREP=$(command -v grep)                                         # installed by default
ZPOOL=$(command -v zpool)                                       # on most Distros
ZFS=$(command -v zfs)                                           # even in basic installs
SYNCOID=$(command -v syncoid)                                   # a few (grep, sed, tail)
NUMFMT=$(command -v numfmt)                                     # aren't used by now
SED=$(command -v sed)
TAIL=$(command -v tail)

TARGET="extBackup"                                              # define the Name of the
                                                                # target Pool
declare -a PRODUCTION=()                                        # Array for local pools
declare -i ZFS_AVAIL                                            # Variables for Space calculation
declare -i ZFS_USED
declare -i ZFS_SIZE
declare -i ZFS_COMBINED
declare -i ZFS_AVAIL_DEST

function do_space_check(){
        for i in "${!PRODUCTION[@]}"; do
                echo -e "\n$txt_ok Calculating: $bldblu${PRODUCTION[$i]}$txtrst"
                                                                # free space
                ZFS_AVAIL=$($ZFS list -o avail,used -t filesystem -pH "${PRODUCTION[$i]}" | $AWK '{ print $1 }')
                                                                # disk space taken
                ZFS_USED=$($ZFS list -o avail,used -t filesystem -pH "${PRODUCTION[$i]}" | $AWK '{ print $2 }')
        
                ZFS_SIZE=$((ZFS_AVAIL+ZFS_USED))                # total size of the pool
                
                echo -e "$txt_info Total: $bldgrn$ZFS_SIZE ($($NUMFMT --to=iec-i $ZFS_SIZE)) $txtrst"
                echo -e "$txt_info Used: $bldgrn$ZFS_USED ($($NUMFMT --to=iec-i $ZFS_USED)) $txtrst"
                echo -e "$txt_info Free: $bldgrn$ZFS_AVAIL ($($NUMFMT --to=iec-i $ZFS_AVAIL)) $txtrst"
                
                ZFS_COMBINED+=ZFS_USED                          # sum of disk space of
        done                                                    # all local pools

                                                                # get the free and used space of pool(s)
                                                                # the 'used' property include
                                                                # the space consumed by snapshots
        ZFS_AVAIL_DEST=$($ZFS list -o avail,used -t filesystem -pH "$TARGET" | $AWK '{ print $1 }')
        echo -e "$txt_info Used Diskspace on local Pool(s): $bldgrn$ZFS_COMBINED ($($NUMFMT --to=iec-i $ZFS_COMBINED)) $txtrst"
        echo -e "$txt_info Free Diskspace on Target Device: $bldgrn$ZFS_AVAIL_DEST ($($NUMFMT --to=iec-i $ZFS_AVAIL_DEST)) $txtrst"

                                                                # abort when the target hasn't
                                                                # enough space
        if [ $ZFS_COMBINED -ge $ZFS_AVAIL_DEST ]; then
                echo -e "\n$txt_wrong$bldred Not enough space on Target Device $txtrst\n$txt_wrong$bldred Aborting..."
                $ZPOOL export $TARGET                           # export the Pool        
                exit 3
        else
                do_sync                                         # start the transfer
        fi
}

function do_sync(){
        for i in "${!PRODUCTION[@]}"; do
                echo -e "$txt_info Transfering: $bldgrn${PRODUCTION[$i]}$txtrst"
                "$SYNCOID" -r "${PRODUCTION[$i]}" $TARGET/"${PRODUCTION[$i]}" 2>/dev/null
        done
        $ZPOOL export $TARGET                                   # export the Pool
}

function do_checks() {
        echo -e "\n$txt_ok Search for Local Pools..."
        LOCALPOOLSTMP="$($ZPOOL list -Ho name)"

        for i in $LOCALPOOLSTMP; do
                echo -e "$txt_info Found Pool: $bldblu $i"
                PRODUCTION+=("$i")
        done

        if [[ "${PRODUCTION[*]}" =~ $TARGET ]]; then
                echo -e "$txt_info Already mounted: $bldblu$TARGET"
                PRODUCTION=(${PRODUCTION[@]/$TARGET})
                do_space_check
        else
                echo -e "\n$txt_ok Search for Backup Pool..."
	        found_pool="$($ZPOOL import | $HEAD -n 1 | $AWK '{ print $2 }')"
                if [ "$TARGET" = "$found_pool" ]; then
                        echo -e "$txt_info importing Pool: $bldblu$TARGET"
                        $ZPOOL import $TARGET
                        echo -e "$txt_info Done"
                        do_space_check
                else
                        echo -e "$txt_wrong No sufficient Target Pool found"
                        exit 1
                fi
        fi
}

function do_init(){
        if [[ $EUID -ne 0 ]]; then
	        echo -e "\n$txt_wrong Insufficient Privileges - You have to be root to run this script\n$txt_wrong Consider the use of sudo\n$txt_wrong Exiting..."
	        exit 1
        else
                do_checks
        fi
}

do_init

# EOF
