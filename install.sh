#!/bin/bash +v

C3P_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
echo "$C3P_PATH"

function Install_netinfod() {
    echo "==== Install netinfod ===="

    sudo apt install -y nodejs npm
    cd $C3P_PATH

    sudo chmod +x netinfod.sh
    ./netinfod.sh
}

function Install_create_ap() {
    echo "==== Install create_ap ===="

    cd $C3P_PATH

    # 1、安装 create_ap 依赖包
    sudo apt install -y build-essential gcc g++ pkg-config make hostapd libpng-dev dnsmasq-base

    # 编译安装 Create_AP, BSD-2-Clause license
    git clone https://github.com/lakinduakash/linux-wifi-hotspot
    cd linux-wifi-hotspot && sudo make install-cli-only

    # 创建配置文件
    sudo create_ap -n --no-virt --freq-band 2.4 --no-dns -g 192.168.10.1 wlan0 Cloud3DPrintBox --mkconfig /etc/create_ap.conf
    sudo chmod 644 /etc/create_ap.conf
}

function Install_inotify() {
    echo "==== Install inotify ===="
    sudo apt install -y inotify-tools
}

function Install_nginx() {
    echo "==== Install nginx ===="

    sudo apt install -y nginx
    cd $C3P_PATH

    sudo cp ./nginx.conf /etc/nginx/
    sudo systemctl restart nginx.service
}

function Env_config() {
    echo "==== Env config ===="
    cd $C3P_PATH

    chmod +x $C3P_PATH/scripts/wifi_creat_ap.sh
    sudo sed -i "/exit 0/i \/${C3P_PATH}\/scripts/wifi_creat_ap.sh" /etc/rc.local 
    sudo mv $C3P_PATH/scripts/system.cfg /etc/
}

git config --global http.proxy http://192.168.0.126:7890/
git config --global https.proxy https://192.168.0.126:7890/

set -e
echo "Getting updates"
sudo apt-get update
echo "Installing Git"
sudo apt-get install git -y
echo "Installing JDK"
sudo apt install openjdk-11-jre -y
if [ -d "$C3P_PATH" ];
then
    echo "Control Application already exists"
    read -p "Do you want to reinstall? (y|n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo systemctl disable c3p
            sudo systemctl stop c3p
            sudo systemctl disable tpcpilocal
            sudo systemctl stop tpcpilocal
            sudo rm /etc/systemd/system/c3p.service
            sudo rm /etc/systemd/system/c3pUpgrade.service
            sudo rm /etc/systemd/system/tpcpilocal.service
            sudo rm -rf $C3P_PATH
        else
            exit 0
    fi
fi

echo "Downloading Control Application"
#git clone -b 1.6.2 https://github.com/cloud-3D-Print/Control-Application
# mv /home/$USER/Cloud3DPrinter $C3P_PATH
# echo "Enabling CSI"
# echo $'\n#Enable CSI\nstart_x=1' | sudo tee -a /boot/config.txt
echo "Configuring config file for user: $USER"
sudo touch $C3P_PATH/config.json
sudo tee $C3P_PATH/config.json &>/dev/null <<EOF
{
    "logFilePath": "$C3P_PATH/logs/control.log",
    "distFolderPath": "$C3P_PATH/dist/",
    "downloadedGcodePath": "$C3P_PATH/gcode/",
    "streamFolderSavePath": "$C3P_PATH/media/",
    "dbFolderPath": "$C3P_PATH/h2db",
    "controlFolderPath": "$C3P_PATH/"
}
EOF
#sed -i "s/pi/$USER/g" control/config.json
echo "Creating system service"
if test -f "/etc/systemd/system/c3p.service"; then
  echo "C3P Service Found"
  echo "Removing existing C3P Service"
  sudo rm /etc/systemd/system/c3p.service
fi
sudo touch /etc/systemd/system/c3p.service
sudo tee /etc/systemd/system/c3p.service &>/dev/null <<EOF
[Unit]
Description=Cloud 3D Print Control Application
After=multi-user.target

[Service]
WorkingDirectory=/home/$USER
ExecStart=/bin/sh -c 'java -cp $C3P_PATH/Cloud3DPrint-v*.jar com.cloud3dprint.Main $C3P_PATH/config.json'
User=root
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "Making Upgrade Service"
if test -f "/etc/systemd/system/c3pUpgrade.service"; then
  echo "C3P Upgrade Service Found"
  echo "Removing existing C3P Upgrade Service"
  sudo rm /etc/systemd/system/c3pUpgrade.service
fi
sudo touch /etc/systemd/system/c3pUpgrade.service
sudo tee /etc/systemd/system/c3pUpgrade.service &>/dev/null <<EOF
[Unit]
Description=Cloud 3D Print Control Application Upgrade
After=multi-user.target

[Service]
WorkingDirectory=/home/$USER
ExecStart=$C3P_PATH/media/upgrade.sh
User=root
Type=simple
EOF

chmod +x $C3P_PATH/tpcpilocal/tpcpilocal
sudo touch $C3P_PATH/tpcpilocal/tpcpi_localconfig.yml

sudo tee $C3P_PATH/tpcpilocal/tpcpi_localconfig.yml &>/dev/null <<EOF
### resolution support 360P, 480P, 720P, 1080P, 2K. default is 720P
resolution: 720P
gpuJPEGQualityRank: 8       ### 1~10
localVidHttpPort: 9988
gRPCPortForPrinterControler: 19988
iNotifyConfFile: $C3P_PATH/AI_Config.json
EOF

sudo touch /etc/systemd/system/tpcpilocal.service
sudo tee /etc/systemd/system/tpcpilocal.service &>/dev/null <<EOF
[Unit]
Description=TPCPI Local Daemon
After=network-online.target syslog.target

[Service]
Type=simple
WorkingDirectory=$C3P_PATH/tpcpilocal
User=$USER
ExecStart=$C3P_PATH/tpcpilocal/tpcpilocal
Restart=on-failure
LimitNOFILE=65536
RestartSec=5s
TimeoutSec=0
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=tpcpilocal

[Install]
WantedBy=multi-user.target
EOF

Install_inotify
Install_netinfod
Install_create_ap
Install_nginx

git config --global --unset http.proxy
git config --global --unset https.proxy

sudo systemctl daemon-reload
sudo systemctl enable c3p.service
sudo systemctl start c3p.service
sudo systemctl enable tpcpilocal.service
sudo systemctl start tpcpilocal.service
printf '=%.0s' {1..45}
echo
printf '=%.0s' {1..45}
echo
cat << "EOF"
   ____ _                 _            
  / ___| | ___  _   _  __| |           
 | |   | |/ _ \| | | |/ _` |           
 | |___| | (_) | |_| | (_| |           
  \____|_|\___/ \__,_|\__,_|           
  _____ ____    ____       _       _   
 |___ /|  _ \  |  _ \ _ __(_)_ __ | |_ 
   |_ \| | | | | |_) | '__| | '_ \| __|
  ___) | |_| | |  __/| |  | | | | | |_ 
 |____/|____/  |_|   |_|  |_|_| |_|\__|
                                       
EOF
printf '=%.0s' {1..45}
echo
printf '=%.0s' {1..45}
echo
echo "Setup complete"
echo "Welcome to Cloud3DPrint! Please go to $(hostname -I) to connect your 3D printer."
echo "Use 'sudo systemctl status c3p' to check the status of the application"
echo "Use 'sudo systemctl reload c3p' to reload the application"
echo "If you are using a Raspberry Pi Camera, please restart the system with 'sudo reboot' for it to be detected"
