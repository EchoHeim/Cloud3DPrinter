#!/bin/bash +v
cd /home/pi/control

#Grab the latest
sudo git pull || true

echo 'Moving head to' 
sudo git reset --hard  || true
sudo git clean -f || true

#Regenerate the GitLog File
sudo chown pi:pi /home/pi/control/logs/GitLog
sudo git log --no-walk --tags --pretty='%H %d' --decorate=full > /home/pi/control/logs/GitLog

