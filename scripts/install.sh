#!/bin/sh

#  install.sh
#  MicFix
#
#  Created by WingLim on 2021/5/15.
#  

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Clean up old installs
function cleanUpOldInstall() {
    sudo launchctl unload /Library/LaunchAgents/com.WingLim.MicFix.plist
    sudo rm -rf /Library/LaunchAgents/com.WingLim.MicFix.plist
}

# Function that exits with an error code and message
function abort() {
    echo $1
    exit 1
}

# Get root permission
if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
f

echo "Removing old installs"
cleanUpOldInstall 2>/dev/null

echo "Copying new files"
sudo cp "$DIR/MicFix" /usr/local/bin/MicFix || abort "Failed to copy MicFix"
sudo cp "$DIR/com.WingLim.MicFix.plist" /Library/LaunchAgents || abort "Failed to copy launchd plist file"

echo "Setting permissions"
sudo chmod 755 /usr/local/bin/MicFix
sudo chmod 644 /Library/LaunchAgents/com.WingLim.MicFix.plist

sudo chown root:wheel /usr/local/bin/MicFix
sudo chown root:wheel /Library/LaunchAgents/com.WingLim.MicFix.plist

echo "Loading launch daemon"
sudo launchctl load /Library/LaunchAgents/com.WingLim.MicFix.plist
