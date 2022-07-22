#!/bin/bash
#####################################################################
###
 # @Author: sjqlwy sjqlwy@yeah.net
 # @Date: 2022-07-08 11:34:06
 # @LastEditors: sjqlwy sjqlwy@yeah.net
 # 创建 NodeJS 监听服务（创建netinfo.txt）
###
#####################################################################

cat << _EOF_ > /tmp/netinfod.service
# /lib/systemd/system/netinfod.service
[Unit]
Description=generate netinfo Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node $HOME/control/wifi/httpServer.js
KillSignal=SIGINT
Restart=on-failure
User=$USER

[Install]
WantedBy=multi-user.target
_EOF_
sudo mv /tmp/netinfod.service /lib/systemd/system/netinfod.service
sudo systemctl enable --now netinfod.service
