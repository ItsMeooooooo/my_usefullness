#!/usr/bin/env bash
#
# Provides      : Shows available ZFS Space
#
# Description   : A short script to check how much Space is used
#                 on local ZFS pools
#
# TODO          : a) Implement output in percent
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

AWK=$(command -v awk)                                           # check for avaible utils
ZPOOL=$(command -v zpool)                                       # on most Distros (except sanoid/ syncoid)
ZFS=$(command -v zfs)                                           # (even in basic installs)
NUMFMT=$(command -v numfmt)                                     # aren't used by now

declare -a PRODUCTION=()                                        # Array for local pools
declare -i ZFS_AVAIL                                            # Variables for Space
declare -i ZFS_USED                                             # calculation
declare -i ZFS_SIZE
declare -i ZFS_COMBINED

function do_space_check(){
        for i in "${!PRODUCTION[@]}"; do
                echo -e "\n$txt_ok Calculating: $bldblu${PRODUCTION[$i]}$txtrst"
                                                                # free space
                ZFS_AVAIL=$($ZFS list -o avail,used -t filesystem -pH "${PRODUCTION[$i]}" | $AWK '{ print $1 }')
                                                                # disk space taken
                ZFS_USED=$($ZFS list -o avail,used -t filesystem -pH "${PRODUCTION[$i]}" | $AWK '{ print $2 }')
        
                ZFS_SIZE=$((ZFS_AVAIL+ZFS_USED))                # total size of the pool
                
                echo -e "$txt_info Total: $bldgrn$ZFS_SIZE ($($NUMFMT --to=iec-i $ZFS_SIZE)) $txtrst"
                echo -e "$txt_info Used: $bldgrn$ZFS_USED ($($NUMFMT --to=iec-i "$ZFS_USED")) $txtrst"
                echo -e "$txt_info Free: $bldgrn$ZFS_AVAIL ($($NUMFMT --to=iec-i "$ZFS_AVAIL")) $txtrst"
                
                ZFS_COMBINED+=ZFS_USED                          # sum of disk space of
        done                                                    # all local pools

                                                                # get the free and used space of pool(s)
                                                                # the 'used' property include
                                                                # the space consumed by snapshots
        echo -e "\n$txt_info Used Diskspace on local Pool(s): $bldgrn$ZFS_COMBINED ($($NUMFMT --to=iec-i $ZFS_COMBINED)) $txtrst"
}

function do_checks() {
        echo -e "\n$txt_ok Search for Local Pools..."
        LOCALPOOLSTMP="$($ZPOOL list -Ho name)"

        for i in $LOCALPOOLSTMP; do
                echo -e "$txt_info Found Pool: $bldblu $i"
                PRODUCTION+=("$i")
        done
        do_space_check
}

do_checks

# EOF
