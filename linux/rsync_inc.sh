#!/usr/bin/env bash
#
# Provides      : Incremental Backup using rsync 
# Description   : A script to perform incremental backups
#                 using rsync.
#                 
#                                  
# NAS Hostname  : 
# NAS Mount:    : 
#
# Created       : 27|03|2021
#
# Modified      : 27|04|2021
#                 - Added the Functionality to write to
#                   two logfiles: debug and info
#                 - Added Commandline Options
#                 - some formatting Improvements
#               : 03|07|2021
#                 - Added a proper help funktion
#                 - changed the location of logfiles
#                 - changed the $SOURCE_DIR Standard location
#                 - modified the rsync options (-HAXh --numeric-ids)
#                 - addressed some minor issues
#                 - Added Licence
#
# Client        : 
# Author        : ItsMe
# Reply to      : itsme@bubbleclub.de
#
# Licence       : MIT Licence
#
# Editor(s)     : vim + joe
#########################################################
#
# OK - Lets Work
#

# set some bash env
set -o errexit								# equivalent to: "set -e" (make the script execution terminate)
set -o nounset								# equivalent to: "set -u" (terminate the script when a variable isn't set)
set -o pipefail								# make the whole pipe fail when a subcommand fails

# set some variables
SCRIPT_NAME="${0##*/}"                      				# this way we do not need to call the 'basename' function
									# shellcheck disable=SC2034
SCRIPT_SHORT_NAME="${SCRIPT_NAME%.*}"       				# the script name without extension


SOURCE_DIR="$HOME/test"				        		# set here the Source Directory you want to backup
                                    					# when the "-d" option on commandline isn't used

BACKUP_DIR="/mnt/Backup"            					# set here the Destination Directory to backup to
                                    					# when the "-b" option on commandline isn't used

LOG_DIR=$BACKUP_DIR

NOW="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly "$NOW"
BACKUP_PATH="${BACKUP_DIR}/${NOW}"
LATEST_LINK="${BACKUP_DIR}/latest"

# check for the rsync binary and exit when not found
RSYNC=$(command -v rsync)
if [[ -z $? ]] ; then                                               	# "-z"  is the bash check for
    echo -e "rsync isn't found\naborting..." | tee -a info.log      	#       an empty string
    echo -e "rsync isn't found\naborting..." | tee -a debug.log     	# "$?"  is the bash variable
    exit                                                            	#       for the exit code of the 
fi                                                                  	#       last command

# Options for rsync
RSYNC_OPTS="-aHAXh --verbose --checksum --delete --numeric-ids"         # "-a"  equivalent to -rlptgoD
                                                                        # "-r"  recursive
                                                                        # "-l"  copy symlinks as symlinks
                                                                        # "-p"  preserve permissions
                                                                        # "-t"  preserve modification times
                                                                        # "-g"  preserve group
                                                                        # "-o"  preserve owner
                                                                        # "-D"  same as --devices --specials
                                                                        # "-h"  human readable
                                                                        # "--numeric-ids" don't map uid/gid values by user/group name


printf '' > "$LOG_DIR"/info.log						# Reset the log files on every run
printf '' > "$LOG_DIR"/debug.log

usage_help(){								# define a short help displayed when for "-h" option
    echo "$SCRIPT_NAME - A script to perform incremental backups using rsync."
    echo
    echo "Usage  : $SCRIPT_NAME [ OPTIONS ]"
    echo "Options:"
    echo "options: -d   Source Directory"
    echo "options: -b   Backup Directory"
    echo "options: -h   Print this Help"
    echo
    echo "if no directories are set on the command line the defaults are used:"
    echo "actual Source Directory: $SOURCE_DIR"
    echo "actual Backup Directory: $BACKUP_DIR"
}
                                                                    
while getopts "d:b:h" opt; do                                       	#       get Commandline Options
  case $opt in                                                      	#       some are given
    d)  if [ -n "$OPTARG" ]; then                                     	#       possible Options are:
            SOURCE_DIR=$OPTARG                                      	# "-d"  Source Directory
        fi                                                          	# "-b"  Backup Directory
        ;;                                                          	# "-h"  for help
    b)  if [ -n "$OPTARG" ]; then                                     	#       all Options are NOT mandatory
            BACKUP_DIR=$OPTARG                                      	#       we set default values at the
            BACKUP_PATH="${BACKUP_DIR}/${NOW}"                      	#       start of the script
            LATEST_LINK="${BACKUP_DIR}/latest"                      
        fi
        ;;
    h)  usage_help
        exit 0
        ;;
        
    \?) echo "Invalid option $opt" >&2
        exit 1
        ;;
  esac
done

		
exec 1>>"$LOG_DIR"/debug.log 2>>"$LOG_DIR"/debug.log			# Redirect both stdout and stderr
									# write to the debug logfile

									# Write to both info and debug
echo "Starting Backup Files at $NOW from $SOURCE_DIR" | tee -a "$LOG_DIR"/info.log

									# run the command
$RSYNC "$RSYNC_OPTS" "${SOURCE_DIR}/" --link-dest="${LATEST_LINK}" --exclude=".cache" "${BACKUP_PATH}"

rm -rf "${LATEST_LINK}"							# remove the symlink to the Directory 'latest'

ln -s "${BACKUP_PATH}" "${LATEST_LINK}"					# create the symlink from the last backup to 'latest'

echo " ✅ " | tee -a "$LOG_DIR"/info.log				# Write to both info and debug

# EOF
