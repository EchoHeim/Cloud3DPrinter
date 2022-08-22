#!/bin/bash    

wifi_shell_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

SYS_CFG=/boot/system.cfg
WORK_DIR=$wifi_shell_DIR/..
WIFI_CFG=$WORK_DIR/wifi/conf/netinfo.txt

IS_AP_MODE="no"
sta_mount=0

function Env_init() {
    source $SYS_CFG         # 加载配置文件

    exec 1> /dev/null
    # without check_interval set, we risk a 0 sleep = busy loop
    if [ ! "$check_interval" ]; then
        echo $(date)" ===> No check interval set!" >> $WORK_DIR/wifi.log
        exit 1
    fi

    sudo kill -9 `pidof wpa_supplicant`
    sleep 10
    sudo systemctl restart NetworkManager
}

function is_network() {
    local Result=no
    if [ $# -eq 0 ]; then
        ping -c 1 $router_ip >/dev/null 2>&1 & wait $!
        [[ $? != 0 ]] && Result=no || Result=yes
    else
        ping -c 1 $router_ip -I $1 >/dev/null 2>&1 & wait $!
        [[ $? != 0 ]] && Result=no || Result=yes
    fi
    echo $Result
}

function Create_AP_ON() {
    if [[ $IS_AP_MODE == "no" && $sta_mount -gt 1 ]]; then
        nmcli device disconnect $wlan
        sudo systemctl restart create_ap
        sleep 2
        IS_AP_MODE="yes"

        echo $(date)" xxxx $wlan Change to ap mode..." >> $WORK_DIR/wifi.log
        if inotifywait $WIFI_CFG --timefmt '%d/%m/%y %H:%M' --format "%T %f" -e MODIFY
        then
            echo -e $(date)" ==== $wlan modify cfg..." >> $WORK_DIR/wifi.log
            IS_AP_MODE="no"
            sleep 4
            source $WIFI_CFG
            sudo sed -i "s/^WIFI_SSID=.*$/WIFI_SSID=$WIFI_SSID/" $SYS_CFG
            sudo sed -i "s/^WIFI_PASSWD=.*$/WIFI_PASSWD=$WIFI_PASSWD/" $SYS_CFG
            [[ $(is_network $eth) == no ]] && Create_AP_OFF
        fi
    fi
}

function Create_AP_OFF() {
    sudo systemctl stop create_ap
    sudo create_ap --fix-unmanaged
    sudo systemctl restart NetworkManager

    [[ $(ifconfig | grep $wlan) == "" ]] && sudo ifconfig $wlan up  # 确保wlan连接启动了

    if [[ $(is_network $wlan) == no ]]; then
        source $SYS_CFG
        echo -e $(date)" ==== $wlan prepare connection... -WIFI_SSID:$WIFI_SSID -WIFI_PASSWD:$WIFI_PASSWD" >> $WORK_DIR/wifi.log
        sudo nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWD ifname $wlan
        sleep 5
    fi
    sta_mount=0
    IS_AP_MODE="no"

    [[ $(is_network $wlan) == no ]] || echo -e $(date)" ==== $wlan network connection..." >> $WORK_DIR/wifi.log
}

function startWifi_sta() {
    source $SYS_CFG
    sta_mount=`expr $sta_mount + 1`
    echo $(date)" .... sta connecting...$sta_mount..." >> $WORK_DIR/wifi.log
    
    if [[ $(is_network $wlan) == no ]]; then
        source $SYS_CFG
        echo -e $(date)" ==== $wlan prepare connection... -WIFI_SSID:$WIFI_SSID -WIFI_PASSWD:$WIFI_PASSWD" >> $WORK_DIR/wifi.log
        sudo nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWD ifname $wlan
        sleep 5
        Create_AP_ON
    else
        sta_mount=0
        IS_AP_MODE="no"
    fi

    # sudo nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWD wep-key-type key ifname $wlan
}

function startWifi() {
    [[ $(ifconfig | grep $wlan) == "" ]] && sudo ifconfig $wlan up  # 确保wlan连接启动了

    if [[ $sta_mount -le 2 ]]; then
        nmcli device connect $wlan      # 连接wifi
        echo $(date)" .... $wlan connecting..." >> $WORK_DIR/wifi.log
        sleep 2
        [[ $(is_network $wlan) == no ]] && startWifi_sta
        [[ $(is_network $wlan) == yes ]] && sta_mount=0 && echo $(date)" [O.K.] $wlan connected!" >> $WORK_DIR/wifi.log
    else
        echo $(date)" xxxx $wlan connection failure... IS_AP_MODE=$IS_AP_MODE ..." >> $WORK_DIR/wifi.log
        Create_AP_ON
    fi
}

#**********************************************************************#

Env_init

while [ 1 ]; do

    if [[ $WIFI_AP == "false" ]]; then
        if [[ $(is_network) == no ]]; then      # 没有网络连接
            echo -e $(date)" ==== No network connection..." >> $WORK_DIR/wifi.log
            startWifi
            sleep 6    # 更改间隔时间，因为有些服务启动较慢，试验后，改的间隔长一点有用
        else
            [[ $(is_network $eth) == yes ]] && nmcli device disconnect $wlan && echo "==== Ethernet Connected, wlan disconnect! ====" >> $WORK_DIR/wifi.log
        fi
    elif [[ $WIFI_AP == "true" ]]; then
        if [[ $(is_network $eth) == yes ]]; then
            sta_mount=6
            [[ $(is_network $wlan) == yes ]] && IS_AP_MODE="no"
            echo -e $(date)" ==== $eth network connection..." >> $WORK_DIR/wifi.log
            startWifi
        elif [[ $(is_network $wlan) == no ]]; then
            [[ $sta_mount -eq 6 ]] && sta_mount=0
            echo -e $(date)" ==== No $wlan network connection..." >> $WORK_DIR/wifi.log
            startWifi
        fi
    fi
    sync
    sleep $check_interval
done
