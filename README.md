# 1. 系统准备

## 1.1 更新系统软件包，安装必要组件
> CB1 的 CONFIG_COMPAT 选项已打开(兼容32位应用程序)

```
sudo apt update && sudo apt upgrade -y
sudo dpkg --add-architecture armhf 
sudo apt install -y git tmux avahi-daemon libc6:armhf openjdk-11-jre
```

## 1.2 设置主机名和时区 
> hostname 和 timezone (可选)

```
sudo hostnamectl set-hostname c3pbox
sudo timedatectl set-timezone Asia/Shanghai
```

## 1.3 添加新组pi, 新用户 pi, 设置密码(c3pbox),  并加入 sudo 用户组

```
sudo useradd -s /bin/bash -U -m -d /home/pi pi
sudo usermod -a -G sudo pi
sudo passwd pi
```

## 1.4 更改sudo缺省密码提示。 
> 编辑 `/etc/sudoers`，在文件最后一行添加如下一行，

``` text
%pi ALL=(ALL) NOPASSWD: ALL
```

## 1.5 重启cb1

```
sudo reboot
```

# ************************************************************************
# 禁用 cedrus 驱动，禁止自动创建 video0 设备，重启生效， siqian建议
cat << _EOF_ > /tmp/disable-cedrus.conf
blacklist sunxi_cedrus
_EOF_
sudo mv /tmp/disable-cedrus.conf /etc/modprobe.d/disable-cedrus.conf

# ************************************************************************


# 2. 软件安装
> pi 用户运行

# 2.1 下载c3p软件包 control.tgz
# 用户pi将软件包上传到$home目录， /home/pi/
# pi ssh登录 - 以用户pi登录系统，执行下面配置命令

# 解压安装包
tar -xvzf control.tgz

# 拷贝service文件 
sudo cp ~/control/services/*.service /etc/systemd/system/


# 启动打印机监控程序c3p
sudo systemctl enable c3p 
sudo systemctl start c3p

# 检查c3p启动是否有错，注意要保证cb1已联网，建议cb1通电或c3p程序启动前已连接摄像头和打印机

sudo systemctl status c3p

# 查看c3p日志
tail -n 100 /home/pi/control/logs/control.log

# 启动摄像监控程序tpcpilocal
sudo systemctl enable tpcpilocal
sudo systemctl start tpcpilocal

# 检查tpcpilocal启动是否有错，第一次启动一定要在c3p之后
sudo systemctl status tpcpilocal

# 用journalctl 查看tpcpilocal日志
sudo journalctl -n 100 -u tpcpilocal

# ************************************************************************

# 登录c3p平台 - https://dashboard.cloud3dprint.com
# 注册后就可以添加在同一局域网的cb1设备（controller），以及其连接的打印机（Marlin only)
# c3p和tpcpiloca第一次运行没有问题，cb1板子重启后，监控程序就会自动启动，
注册的c3p用户无须和cb1在同一个局域网也可以管理cb1（controller）和打印机
