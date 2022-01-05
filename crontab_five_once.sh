#!/bin/bash
echo 2 |select-editor
#可去除crontab -l，重新写入新的计时器
(echo "*/5 * * * * /root/docker_info_pushgateway/docker_status.sh"; crontab -l) | crontab
#(echo "*/1 * * * * /root/tmp/docker_status.sh"; crontab -l) | crontab
systemctl restart cron.service