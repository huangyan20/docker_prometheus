#!/bin/bash

#使用说明
#过滤出docker容器信息，非up状态和unhealthy状态，往prometheus网关推送信息，crontan定时5分钟推送一次
#/var/log/prometheus_docker_info/white_list白名单文件，将需要过滤的容器完整名以回车的方式填入其中，不筛选此容器信息告警
#touch /var/log/prometheus_docker_info/record_down_info.log临时记录非up容器名文件
#touch /var/log/prometheus_docker_info/record_unhealthy_info.log临时记录unhealthy容器名文件
#compute02地址记得改

#create folder
if [ ! -d "/var/log/prometheus_docker_info" ]; then
     mkdir /var/log/prometheus_docker_info
     touch /var/log/prometheus_docker_info/record_down_info.log
     touch /var/log/prometheus_docker_info/record_unhealthy_info.log
     touch /var/log/prometheus_docker_info/white_list.txt
     echo "container_name" >> /var/log/prometheus_docker_info/white_list.txt
fi

#define value
var_hosname_label=$(hostname)
var_dockername_down_container_label=$(cat /var/log/prometheus_docker_info/white_list.txt |grep -v "#" |xargs|sed 's/[ ][ ]*/|/g' |xargs -I "{}" sh -c "docker ps -a|grep -vi "up" |grep -vE '({})'|awk 'NR>1{print \$(NF)}'|xargs|sed 's/[ ][ ]*/$/g'")
var_error_container_status_value=$(cat /var/log/prometheus_docker_info/white_list.txt |grep -v "#" |xargs|sed 's/[ ][ ]*/|/g' |xargs -I "{}" sh -c "docker ps -a|grep -vi "up" |grep -vE '({})'|awk 'NR>1{print \$(NF)}'|wc -l")
var_dockername_unhealthy_container_label=$(cat /var/log/prometheus_docker_info/white_list.txt |grep -v "#" |xargs|sed 's/[ ][ ]*/|/g' |xargs -I "{}" sh -c "docker ps -a|grep -ai "unhealthy" |grep -vE '({})'|awk '{print \$(NF)}'|xargs|sed 's/[ ][ ]*/$/g'")
var_error_container_status_value_unhealthy=$(cat /var/log/prometheus_docker_info/white_list.txt |grep -v "#" |xargs|sed 's/[ ][ ]*/|/g' |xargs -I "{}" sh -c "docker ps -a|grep -ai "unhealthy" |grep -vE '({})'|awk '{print \$(NF)}'|wc -l")

#var_dockername_down_container_label=$(docker ps -a|grep -vi "up" |awk 'NR>1{print $(NF)}'|xargs|sed 's/[ ][ ]*/_/g')
#var_error_container_status_value=$(docker ps -a|grep -vi "up" |awk 'NR>1{print $(NF)}'|wc -l)
#var_dockername_unhealthy_container_label=$(docker ps -a|grep -ai "unhealthy" |awk '{print $(NF)}'|xargs|sed 's/[ ][ ]*/$/g')
#var_error_container_status_value_unhealthy=$(docker ps -a|grep -ai "unhealthy" |awk '{print $(NF)}'|wc -l)

var_down='down'
var_unhealthy='unhealthy'

#push gateway error container status
if [ $(cat /var/log/prometheus_docker_info/record_down_info.log |wc -l) == 0 ]; then
     echo $var_dockername_down_container_label > /var/log/prometheus_docker_info/record_down_info.log
     echo "docker_info_down $var_error_container_status_value" | curl --data-binary @- http://compute02:9091/metrics/job/$var_hosname_label/type_down/$var_down/container_name/$var_dockername_down_container_label
else
     var_dockername_temporary=$(cat /var/log/prometheus_docker_info/record_down_info.log)
     curl -X DELETE http://compute02:9091/metrics/job/$var_hosname_label/type_down/$var_down/container_name/$var_dockername_temporary
     echo $var_dockername_down_container_label > /var/log/prometheus_docker_info/record_down_info.log
     echo "docker_info_down $var_error_container_status_value" | curl --data-binary @- http://compute02:9091/metrics/job/$var_hosname_label/type_down/$var_down/container_name/$var_dockername_down_container_label
fi

#push gateway unhealthy container status
if [ $(cat /var/log/prometheus_docker_info/record_unhealthy_info.log |wc -l) == 0 ]; then
     echo $var_dockername_unhealthy_container_label > /var/log/prometheus_docker_info/record_unhealthy_info.log
     echo "docker_info_unhealthy $var_error_container_status_value_unhealthy" | curl --data-binary @- http://compute02:9091/metrics/job/$var_hosname_label/type_unhealthy/$var_unhealthy/container_name/$var_dockername_unhealthy_container_label
else
     var_dockername_temporary_unhealthy=$(cat /var/log/prometheus_docker_info/record_unhealthy_info.log)
     curl -X DELETE http://compute02:9091/metrics/job/$var_hosname_label/type_unhealthy/$var_unhealthy/container_name/$var_dockername_temporary_unhealthy
     echo $var_dockername_unhealthy_container_label > /var/log/prometheus_docker_info/record_unhealthy_info.log
     echo "docker_info_unhealthy $var_error_container_status_value_unhealthy" | curl --data-binary @- http://compute02:9091/metrics/job/$var_hosname_label/type_unhealthy/$var_unhealthy/container_name/$var_dockername_unhealthy_container_label
fi
