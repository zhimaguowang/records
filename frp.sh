#! /bin/bash
#
# 64位的 frp 内网穿透自动安装
#
echo 自动安装64位的frp server

apt update -y

apt install wget -y

# 下载 frp 安装包amd64位
cd /tmp

wget https://github.com/fatedier/frp/releases/download/v0.45.0/frp_0.45.0_linux_amd64.tar.gz

tar -zxf frp_0.45.0_linux_amd64.tar.gz -C /usr/local/bin/

mv /usr/local/bin/frp_* /usr/local/bin/frp/


# 写入frp的控制文件
mkdir -p /etc/frp/

cat>/etc/frp/frps.ini<<EOF
[common]
bind_port = 50000
bind_udp_port = 50001
authentication_method = token
token = e02bd4e4a3a6f3ce3f23535185c68fb1

EOF

# 写入frp的systemd启动项
cat>/lib/systemd/system/frp.service<<EOF

[Unit]
Description=Frp is a fast reverse proxy server
Documentation=https://github.com/fatedier/frp/blob/dev/README.md
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frp/frps -c /etc/frp/frps.ini
KillMode=process
Restart=on-failure
RestartSec=2s

[Install]
WantedBy=multi-user.target

EOF

#写入定时重启的Systemd项目
cat>/lib/systemd/system/frp-restart.service<<EOF

[Unit]
Description=Restart frp
[Service]
Type=simple
ExecStart=/bin/sh /usr/local/bin/frp/restart

EOF

#写入重启的执行脚本
cat>/usr/local/bin/frp/restart<<EOF

#!/bin/sh
systemctl restart frp

EOF

#写入定时重启的计时器timer项目
cat>/lib/systemd/system/frp-restart-cron.timer<<EOF

[Unit]
Description=Retart frp ervery 2 hours

[Timer]
OnBootSec=1h
#首次启动后多少小时执行
OnUnitActiveSec=2h
#每隔多少小时执行
Unit=frp-restart.service

[Install]
WantedBy=multi-user.target

EOF

# 启动Goflyway主服务和“定时重启计划任务服务”。
systemctl start frp
systemctl start frp-restart-cron.timer
systemctl enable frp
systemctl enable frp-restart-cron.timer
