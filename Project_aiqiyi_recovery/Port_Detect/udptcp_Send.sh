#!/bin/bash
# 端口检测脚本

# 检查是否提供了目标 IP 地址
if [ -z "$1" ]; then
    echo "用法: $0 <目标IP地址>"
    echo "示例: $0 192.168.1.1"
    exit 1
fi

# 检测端口列表
ports=(20000 25000 30000)

# 检测 TCP 端口
echo "检测 TCP 端口..."
for port in "${ports[@]}"; do
    echo "正在检测 TCP 端口 $port ..."
    nc -zv "$1" "$port" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "TCP 端口 $port 正在运行"
    else
        echo "TCP 端口 $port 未运行"
    fi
done

# 检测 UDP 端口
echo "检测 UDP 端口..."
for port in "${ports[@]}"; do
    echo "正在检测 UDP 端口 $port ..."
    nc -zv -u "$1" "$port" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "UDP 端口 $port 正在运行"
    else
        echo "UDP 端口 $port 未运行"
    fi
done