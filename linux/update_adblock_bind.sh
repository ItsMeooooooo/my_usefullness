#!/usr/bin/env bash
#
# Provides      : Update of the adblock in bind 9
# Description   : A script to perform updates
#                 to the adblock file used to block ads
#                 LAN wide
#                 Included are common ad servers, 
#                 Youtube ads, Win10/ Office Telemtry, Fake Streaming and Scam sites
# URIs          : https://pgl.yoyo.org/adservers/serverlist.php?hostformat=bindconfig&showintro=0&mimetype=plaintext
#                 https://raw.githubusercontent.com/anudeepND/youtubeadsblacklist/master/domainlist.txt
#                 https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Win10Telemetry
#                 https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/MS-Office-Telemetry
#                 https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Streaming
#
# Created       : 12|08|2021
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

CURL=$(command -v curl)                                         # We do not test if its installed
SED=$(command -v sed)                                           # those are installed in most distributions
CAT=$(command -v cat)                                           # even in the most basic install environment
M4=$(command -v m4)                                             # we simply try to fail (more or less) gracefully (look above)
SCTL=$(command -v systemctl)                                    # Neither we do any output because the script is meant to
NAMED="named-chroot.service"                                    # run as cronjob
                                                                # TODO: Implement some kind of logging

CURRENT_FILE_DIR="/var/named/chroot/etc/"
CURRENT_FILE="adblock"

TMP_ADS=$(echo 'mkstemp(/tmp/ads-XXXXXX)' | $M4)                # Create temp files
TMP_YT=$(echo 'mkstemp(/tmp/ads-XXXXXX)' | $M4)                 # This should be POSIX compatible
TMP_COMBINED=$(echo 'mkstemp(/tmp/ads-XXXXXX)' | $M4)           # 
                                                                # this:
                                                                # TMPFILE=$(mktemp /tmp/foo-XXXXXX)
                                                                # will work on any Linux just fine anyway


URI_ADS="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=bindconfig&showintro=0&mimetype=plaintext"
URI_YT="https://raw.githubusercontent.com/anudeepND/youtubeadsblacklist/master/domainlist.txt"
URI_MS="https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Win10Telemetry"
URI_OFFICE="https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/MS-Office-Telemetry"
URI_FAKESTREAM="https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Streaming"

DL_URIS=("$URI_YT" "$URI_MS" "$URI_OFFICE" "$URI_FAKESTREAM")

$CURL "$URI_ADS" -so "$TMP_ADS"

for i in "${!DL_URIS[@]}"; do
        $CURL "${DL_URIS[$i]}" -s >> "$TMP_COMBINED"
done

$SED -i 's/null.zone.file/\/etc\/null.zone.file/g' "$TMP_ADS"   # sadly the lists have a slightly different format than that whats needed
$SED -i '/#/d' "$TMP_COMBINED"                                  # so we have to adapt the lists to our needs
$SED -i '/^$/d' "$TMP_COMBINED"                                 # the first one changes "null.zone.file" to "/etc/null.zone.file"
                                                                # the second converts the hostnames to a bind zone file
                                                                # we remove all lines with a bash comment and empty lines

while IFS= read -r line; do 
        printf 'zone "%s" { type master; notify no; file "/etc/null.zone.file"; };\n ' "$line" >>"$TMP_ADS";
done <"$TMP_COMBINED"


printf "" > $CURRENT_FILE_DIR$CURRENT_FILE                      # empty the old file

$CAT "$TMP_ADS" > $CURRENT_FILE_DIR$CURRENT_FILE                # fill it with the new content

$SCTL reload $NAMED                                             # reload the bind 9 config and zone file

trap 'rm -f $TMP_ADS $TMP_YT $TMP_COMBINED' EXIT                # clean the garbage - delete the tmp files

# EOF
