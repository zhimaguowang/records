#! /bin/bash
#
# 64 位的 goflyway 自动安装
#

echo 自动安装64位goflyway

apt update -y

apt install wget -y

# 下载goflyway安装包64位
cd /tmp

wget https://github.com/coyove/goflyway/releases/download/1.3.0a/goflyway_linux_amd64.tar.gz

mkdir -p /usr/local/bin/goflyway/

tar -zxf goflyway_linux_amd64.tar.gz -C /usr/local/bin/goflyway/

# 写入goflyway的systemd启动项
cat>/lib/systemd/system/goflyway.service<<EOF

[Unit]
Description=Goflyway is an encrypted HTTP server
Documentation=https://github.com/coyove/goflyway/blob/v1.0/script/man.md
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/goflyway/goflyway -k=此处写密码 -l=:2086 lv=off
KillMode=process
Restart=on-failure
RestartSec=2s

[Install]
WantedBy=multi-user.target

EOF

#写入定时重启的Systemd项目
cat>/lib/systemd/system/goflyway-restart.service<<EOF

[Unit]
Description=Restart Goflyway
[Service]
Type=simple
ExecStart=/bin/sh /usr/local/bin/goflyway/restart

EOF

#写入定时重启的计时器timer项目
cat>/lib/systemd/system/goflyway-restart-cron.timer<<EOF

[Unit]
Description=Retart goflyway ervery 1 hours

[Timer]
OnBootSec=2h
#首次启动后多少小时执行
OnUnitActiveSec=1h
#每隔多少小时执行
Unit=goflyway-restart.service

[Install]
WantedBy=multi-user.target

EOF

#写入重启的执行脚本
cat>/usr/local/bin/goflyway/restart<<EOF

#!/bin/sh
systemctl restart goflyway

EOF

systemctl start goflyway
systemctl enable goflyway
