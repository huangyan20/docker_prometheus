# docker_prometheus
主要收集docker ps -a 容器信息  
推送至prometheus pushgateway网关  
收集非up状态的容器，以及unhealthy不健康的容器  
使prometheus及时告警  

# kibana+elasticsearch+fluentd
docker_fluentd文件夹主要是用于EFK实验  
构建kibana+elasticsearch  
构建fluentd，将数据收集后指向es（实验中）  

# kibana+elasticsearch+openstack（fluentd）
更改上面方案，openstack在部署时已经加入fluentd  
构建第三方kibana+elasticsearch，仿照openstack（kibana+elasticsearch+fluentd）  
更改openstack（fluentd）配置文件，将地址指向第三方kibana+elasticsearch即可  
