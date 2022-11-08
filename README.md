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

## 1.5 重启

```
sudo reboot
```

# 2. 软件安装
> pi 用户运行

## 2.1 下载c3p软件包

> 在用户 pi `$home`目录下 (/home/pi)

``` bash
cd  ~
git clone --depth 1 https://github.com/EchoHeim/Cloud3DPrinter.git
mv Cloud3DPrinter control
```

## 2.2 拷贝service文件

``` bash
sudo cp ~/control/services/*.service /etc/systemd/system/
```

## 2.3 启动打印机监控程序c3p

``` bash
sudo systemctl enable c3p 
sudo systemctl start c3p
```

- 检查c3p启动状态
    
    > 注意要保证cb1已联网，建议系统开机或c3p程序启动前已连接摄像头和打印机

    ``` bash
    sudo systemctl status c3p
    ```

- 查看c3p日志

    ``` bash
    tail -n 100 /home/pi/control/logs/control.log
    ```

## 2.4 启动摄像监控程序tpcpilocal

``` bash
sudo systemctl enable tpcpilocal
sudo systemctl start tpcpilocal
```

- 检查tpcpilocal启动状态

    >第一次启动一定要在c3p之后

    ``` bash
    sudo systemctl status tpcpilocal
    ```

- 查看tpcpilocal日志

    ``` bash
    sudo journalctl -n 100 -u tpcpilocal
    ```

# 3. 登录c3p平台

<https://dashboard.cloud3dprint.com>

注册后就可以添加在同一局域网的主控设备（controller），以及其连接的打印机（Marlin only)。

c3p和tpcpiloca第一次运行没有问题，系统重启后，监控程序就会自动启动；

注册的c3p用户无须和系统控制板在同一个局域网也可以管理主控板（controller）和打印机；
