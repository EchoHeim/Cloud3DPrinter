#!/bin/bash
#####################################################################
###
 # @Author: sjqlwy sjqlwy@yeah.net
 # @Date: 2022-07-09 11:34:06
 # @LastEditors: sjqlwy sjqlwy@yeah.net
 # 创建 文件变动 监听服务（监听netinfo.txt）
###
#####################################################################
# 1、安装 create_ap 依赖包
sudo apt install -y build-essential gcc g++ pkg-config make hostapd libpng-dev dnsmasq-base

# 编译安装 Create_AP, BSD-2-Clause license
git clone https://github.com/lakinduakash/linux-wifi-hotspot
cd linux-wifi-hotspot && sudo make install-cli-only

chmod +x $HOME/control/update.sh

# 创建配置文件
sudo create_ap -n --no-virt --freq-band 2.4 --no-dns -g 192.168.10.1 wlan0 Cloud3DPrintBox --mkconfig /etc/create_ap.conf
sudo chmod 644 /etc/create_ap.conf

#####################################################################
# 文件变动监听服务
#####################################################################
# SERVICE
cat << _EOF_ > /tmp/netinfo_mon.service
# /lib/systemd/system/netinfo_mon.service
[Unit]
Description = netinfo_mon.service

[Service]
ExecStart=/usr/bin/bash $HOME/scripts/con_wifi > /dev/null 2>&1
User=$USER
_EOF_
sudo mv /tmp/netinfo_mon.service /lib/systemd/system/netinfo_mon.service

# PATH
cat << _EOF_ > /tmp/netinfo_mon.path
# /lib/systemd/system/netinfo_mon.path
[Unit]
Description = Monitor netinfo change

[Path]
PathChanged = $HOME/control/wifi/conf/netinfo.txt
MakeDirectory = no
Unit = netinfo_mon.service

[Install]
WantedBy = multi-user.target
_EOF_
sudo mv /tmp/netinfo_mon.path /lib/systemd/system/netinfo_mon.path
sudo systemctl enable --now netinfo_mon.path