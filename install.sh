#!/bin/bash +v

function Install_netinfod() {
    echo "==== Install netinfod ===="

    sudo apt install -y nodejs npm
    cd /home/$USER/control

    sudo chmod +x netinfod.sh
    ./netinfod.sh
}

function Install_create_ap() {
    echo "==== Install create_ap ===="

    cd $HOME/control

    # 1、安装 create_ap 依赖包
    sudo apt install -y build-essential gcc g++ pkg-config make hostapd libpng-dev dnsmasq-base

    # 编译安装 Create_AP, BSD-2-Clause license
    git clone https://github.com/lakinduakash/linux-wifi-hotspot
    cd linux-wifi-hotspot && sudo make install-cli-only

    # chmod +x $HOME/control/update.sh

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
    cd $HOME/control

    sudo cp ./nginx.conf /etc/nginx/
    sudo systemctl restart nginx.service
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
if [ -d "/home/$USER/control" ];
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
      sudo rm -rf /home/$USER/control
    else
      exit 0
  fi
fi
echo "Downloading Control Application"
#git clone -b 1.6.2 https://github.com/cloud-3D-Print/Control-Application
mv /home/$USER/Control-Application /home/$USER/control
echo "Enabling CSI"
echo $'\n#Enable CSI\nstart_x=1' | sudo tee -a /boot/config.txt
echo "Configuring config file for user: $USER"
sudo touch /home/$USER/control/config.json
sudo tee /home/$USER/control/config.json &>/dev/null <<EOF
{
  "logFilePath": "/home/$USER/control/logs/control.log",
  "distFolderPath": "/home/$USER/control/dist/",
  "downloadedGcodePath": "/home/$USER/control/gcode/",
  "streamFolderSavePath": "/home/$USER/control/media/",
  "dbFolderPath": "/home/$USER/control/h2db",
  "controlFolderPath": "/home/$USER/control/"
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
ExecStartPre=/home/$USER/control/update.sh
ExecStart=/bin/sh -c 'java -cp /home/$USER/control/Cloud3DPrint-v*.jar com.cloud3dprint.Main /home/$USER/control/config.json'
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
ExecStart=/home/$USER/control/media/upgrade.sh
User=root
Type=simple
EOF

echo "Creating update file"
sudo touch /home/$USER/control/update.sh
sudo tee /home/$USER/control/update.sh &>/dev/null <<EOF
#!/bin/bash +v
cd /home/$USER/control
sudo git pull || true
EOF
sudo chmod +x /home/$USER/control/update.sh

chmod +x /home/$USER/control/tpcpilocal/tpcpilocal

sudo touch /home/$USER/control/tpcpilocal/tpcpi_localconfig.yml
sudo tee /home/$USER/control/tpcpilocal/tpcpi_localconfig.yml &>/dev/null <<EOF
### resolution support 360P, 480P, 720P, 1080P, 2K. default is 720P
resolution: 720P
gpuJPEGQualityRank: 8    ### 1~10
localVidHttpPort: 9988
gRPCPortForPrinterControler: 19988
iNotifyConfFile: /home/$USER/control/AI_Config.json
EOF

sudo touch /etc/systemd/system/tpcpilocal.service
sudo tee /etc/systemd/system/tpcpilocal.service &>/dev/null <<EOF
[Unit]
Description=TPCPI Local Daemon
After=network-online.target syslog.target

[Service]
Type=simple
WorkingDirectory=/home/$USER/control/tpcpilocal
User=$USER
ExecStart=/home/$USER/control/tpcpilocal/tpcpilocal
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


