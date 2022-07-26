#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# Provides      : Shows available ZFS Space
#
# Description   : A short script to check how much Space is used
#                 on local ZFS pools
#
# TODO          : a) Implement a kind of error management
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
ZPOOL=$(command -v zpool)                                       # on most Distros 
ZFS=$(command -v zfs)                                           # (even in basic installs)

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

                                                                # calculate percentages
                pZFS_AVAIL=$(awk 'BEGIN { print ('$ZFS_AVAIL' / '$ZFS_SIZE' * 100)"%" }')
                pZFS_USED=$(awk 'BEGIN { print ('$ZFS_USED' / '$ZFS_SIZE' * 100)"%" }')

                                                                # tell the world
                echo -e "$txt_info Total:$bldgrn $(convert_numbers $ZFS_SIZE) $txtrst"
                echo -e "$txt_info Used: $bldgrn $(convert_numbers "$ZFS_USED") ($pZFS_USED) $txtrst"
                echo -e "$txt_info Free: $bldgrn $(convert_numbers "$ZFS_AVAIL") ($pZFS_AVAIL) $txtrst"

                ZFS_COMBINED+=ZFS_USED                          # sum of disk space of
        done                                                    # all local pools

                                                                # get the free and used space of pool(s)
                                                                # the 'used' property include
                                                                # the space consumed by snapshots
        echo -e "\n$txt_info Used Diskspace on local Pool(s): $bldgrn $(convert_numbers $ZFS_COMBINED) $txtrst"
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

# To get rid of numfmt we convert the units by ourselves
# awk is used for calculations because bash/ zsh only 
# handle integers
function convert_numbers() {
        # Kibibyte [KiB] (2^10)
        if (( "${#1}" >= 4 )) && (( "${#1}" <7 )); then
               $AWK 'BEGIN { print ('$1' / (1024 ** 1))"KiB" }'
        fi
        # Mebibyte [MiB] (2^20)
        if (( "${#1}" >= 7 )) && (( "${#1}" <10 )); then
               $AWK 'BEGIN { print ('$1' / (1024 ** 2))"MiB" }'
        fi
        # Gibibyte [KiB] (2^30)
        if (( "${#1}" >= 10 )) && (( "${#1}" <13 )); then
                $AWK 'BEGIN { print ('$1' / (1024 ** 3))"GiB" }'
        fi
        # Tebibyte [TiB] (2^40)
        if (( "${#1}" >= 13 )) && (( "${#1}" <16 )); then
                $AWK 'BEGIN { print ('$1' / (1024 ** 4))"TiB" }'
        fi
        # Pebibyte [PiB] (2^50)
        if (( "${#1}" >= 16 )) && (( "${#1}" <19 )); then
                $AWK 'BEGIN { print ('$1' / (1024 ** 5))"PiB" }'
        fi
        # Exbibyte [EiB] (2^60)
        if (( "${#1}" >= 19 )) && (( "${#1}" <22 )); then
                $AWK 'BEGIN { print ('$1' / (1024 ** 6))"EiB" }'
        fi
}


do_checks

# EOF
