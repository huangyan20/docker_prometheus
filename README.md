# docker_prometheus
# 主要收集docker ps -a 容器信息
# 推送至prometheus pushgateway网关
# 收集非up状态的容器，以及unhealthy不健康的容器
# 使prometheus及时告警
