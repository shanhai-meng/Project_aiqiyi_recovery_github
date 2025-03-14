#!/bin/bash
# 端口探测脚本


function container() {
    container_id=$(docker ps | grep -v network | tail -1 | awk '{print $1}')
    if [ -z "$container_id" ]; then
        echo "未找到匹配的容器 ID，请检查容器名称是否正确。"
        exit 1
    fi
    container_pid=$(docker inspect -f '{{.State.Pid}}' "$container_id")
    if [ -z "$container_pid" ]; then
        echo "未找到容器的 PID，请检查容器是否正在运行。"
        exit 1
    fi
    nsenter -t "$container_pid" -n curl myip.ipip.net
    # 容器udp探测
    for port in 20000 25000 30000; do
        timeout 1m nsenter -t "$container_pid" -n nc -l -u "$port" &
    done
    # 容器tcp探测
    for port in 20000 25000 30000; do
        timeout 1m nsenter -t "$container_pid" -n nc -l -p "$port" &
    done
}



function host() {
    curl myip.ipip.net
    # 主机udp探测
    for port in 20000 25000 30000; do
        timeout 1m nc -l -u "$port"  &
    done 
    # 主机tcp探测
    for port in 20000 25000 30000; do
        timeout 1m nc -l -p "$port"  &
    done  
}

# 选择探测方式
function port_detection() {
    if docker ps | grep network > /dev/null; then
        echo "容器探测中..."
        container

    else
        echo "主机探测中..."
        host
    fi
}

port_detection 
