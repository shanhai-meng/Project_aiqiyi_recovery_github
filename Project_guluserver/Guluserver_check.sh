#!/bin/bash
################################################################################
# 内容概要：Guluserver故障检测脚本
# 作者信息：Mengrun<Mengrun@onething.net>
# 更新时间：2025-02-28 2:00
################################################################################

################################################################################
# 日志输出方法定义
################################################################################

function Color_Red() {
  echo -e "\033[31m${1}\033[0m"
}
function Color_Green() {
  echo -e "\033[32m${1}\033[0m"
}
function Color_Yellow() {
  echo -e "\033[33m${1}\033[0m"
}

function LOG_INFO() {
  echo -e "\033[32m$(date +"%Y-%m-%d %H:%M:%S")\tINFO\t${1}\033[0m"
}

function LOG_WARN() {
  echo -e "\033[33m$(date +"%Y-%m-%d %H:%M:%S")\tWARN\t${1}\033[0m"
}

function LOG_ERROR() {
  echo -e "\033[31m$(date +"%Y-%m-%d %H:%M:%S")\tERROR\t${1}\033[0m"
}
################################################################################
# 常量定义
################################################################################

datenew=$(date +"%Y-%m-%d %H:%M:%S")

################################################################################
# 函数定义
################################################################################

# 加载特效(动态显示 .、..、...)
function Dynamic() {
    local message="$1"  # 获取传递的字符串
    interval=0.5
    for dots in "." ".." "..."; do
        echo -ne "\r${message} $dots"  # 将动态点加到字符串后面
        sleep "$interval"
    done
}

# 更新 YUM 源
function yum_repos() {
    Color_Yellow "正在备份 YUM 源..."
    cd /etc/yum.repos.d/ 
    mkdir backup  > /dev/null 2>&1
    mv CentOS-* backup/  backup  > /dev/null 2>&1
    wget -O --timeout=3 /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null 2>&1
    cd - > /dev/null 2>&1
    echo -e "\033[32mYUM 源备份完成。\033[0m"
}

# 安装必要的工具
function install_Toolset() {
    echo -e "\033[33m正在安装必要的工具...\033[0m"
    yum -y install jq >/dev/null
    echo -e "\033[32m工具安装完成。\033[0m"
}

# 查看实例缓存情况
function Business_Cache() {
    echo -e "\033[33m查看挂载点缓存情况：\033[0m"
    # 初始化关联数组
    declare -A counters
    for i in {0..90..10}; do
        counters["${i}-$(($i + 10))%"]=0  # 正确生成区间范围
    done

    # 提取使用率数据并保存到文件
    df -Th | grep storage | grep -v _vg_lv | awk '{print $6}' | awk -F'%' '{print $1}' > usage_data.txt

    # 定义统计函数
    count_usage() {
        local usage=$(( $1 ))  # 强制转换为整数
        if (( usage >= 0 && usage <= 10 )); then
            ((counters["0-10%"]++))
        elif (( usage > 10 && usage <= 20 )); then
            ((counters["10-20%"]++))
        elif (( usage > 20 && usage <= 30 )); then
            ((counters["20-30%"]++))
        elif (( usage > 30 && usage <= 40 )); then
            ((counters["30-40%"]++))
        elif (( usage > 40 && usage <= 50 )); then
            ((counters["40-50%"]++))
        elif (( usage > 50 && usage <= 60 )); then
            ((counters["50-60%"]++))
        elif (( usage > 60 && usage <= 70 )); then
            ((counters["60-70%"]++))
        elif (( usage > 70 && usage <= 80 )); then
            ((counters["70-80%"]++))
        elif (( usage > 80 && usage <= 90 )); then
            ((counters["80-90%"]++))
        elif (( usage > 90 && usage <= 100 )); then
            ((counters["90-100%"]++))
        fi
    }

    # 从文件中读取使用率并统计
    while read -r use_percent; do
        count_usage "$use_percent"
    done < usage_data.txt

    # 输出统计结果
    for range in "${!counters[@]}"; do
        if [[ ${counters[$range]} -gt 0 ]]; then  # 只输出实例数不为 0 的区间
            LOG_INFO "有 ${counters[$range]} 个挂载点缓存在 $range"
        fi
    done
    rm -rf usage_data.txt
}

# 检查实例数
function check_pod() {
    echo -e "\033[33m检查实例数...\033[0m"
    Theoretical_sum=$(jq -r '(.per_line_bandwidth * (.line_number / 50))' /etc/xyapp/export_bandwidth_corrected.json)
    Practical_sum=$(lvs | grep -vE "LSize|_vg_lv" | wc -l)
    Pod_sum=$(docker ps | grep -vE "CONTAINER|network" | wc -l)
    LOG_INFO "理论实例数：\t\t$Theoretical_sum"
    LOG_INFO "当前实例数：\t\t$Pod_sum"
    # LOG_INFO "存储卷数量：\t\t$Practical_sum"
}

# 检查 Ping 连通性
function Ping_check() {
    runmode=$(awk '/runmode/ && /host/' /tmp/multidialstatus.json)
    if  [[ -n $runmode ]];then
        Color_Yellow "正在测试主机 IPv4 连通性..."
        ping -c 1 www.baidu.com > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            LOG_INFO "主机 IPv4 连通性测试成功。"
        else
            LOG_ERROR "主机 IPv4 连通性测试失败。"
        fi
    else
        success_count=0
        failure_count=0
        Color_Yellow "正在测试容器 $value 的 IPv4 连通性..."
        docker ps | grep network | awk '{print $1}' > "$temp_file"
        while read -r value; do
            if docker exec "$value" sh -c "ping -c 1 www.baidu.com" > /dev/null 2>&1; then
                ((success_count++))
            else
                LOG_ERROR "容器 $value 的 IPv4 连通性测试失败。"
                ((failure_count++))
            fi
        done <  "$temp_file"
        rm -f "$temp_file"  # 删除临时文件
        LOG_INFO "测试完成。"
        LOG_INFO "Ping ipv4成功数量: $success_count"
        LOG_ERROR "Ping ipv4失败数量: $failure_count"
    fi
}

function Ping6_check() {
    runmode=$(awk '/runmode/ && /host/' /tmp/multidialstatus.json)
    if  [[ -n $runmode ]];then
        Color_Yellow "正在测试主机 IPv6 连通性..."
        ping6 -c 1 www.baidu.com > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            LOG_INFO "主机 IPv6 连通性测试成功。"
        else
            LOG_ERROR "主机 IPv6 连通性测试失败。"
        fi
    else
        success_count1=0
        failure_count1=0
        Color_Yellow "正在测试容器 $value 的 IPv6 连通性..."
        docker ps | grep network | awk '{print $1}' > "$temp_file"
        while read -r value; do
            if docker exec "$value" sh -c "ping6 -c 1 www.baidu.com" > /dev/null 2>&1; then
                ((success_count1++))
            else
                LOG_ERROR "容器 $value 的 IPv6 连通性测试失败。"
                ((failure_count1++))
            fi
        done <  "$temp_file"
        LOG_INFO "测试完成。"
        LOG_INFO "Ping ipv6成功数量: $success_count1"
        LOG_ERROR "Ping ipv6失败数量: $failure_count1"
    fi
}

# 统计 NAT 类型
function nat_sum() {
    temp_file="/tmp/udp_nat_values.txt"
    # 提示正在判断 NAT 类型
    Color_Yellow "正在判断 NAT 类型..."
    # 从 JSON 文件中提取 udp_nat 的值并保存到临时文件
    cat /tmp/net_link_prober.json | python -m json.tool | grep -w "udp_nat" | awk -F': ' '{print $2}' > "$temp_file"
    # 检查临时文件是否存在
    if [ ! -f "$temp_file" ]; then
        echo "临时文件未创建成功，请检查输入文件是否正确。"
    fi
    # 初始化计数器
    declare -A nat_counts
    # 读取临时文件并统计每个值的出现次数
    while read -r value; do
        # 去掉可能的逗号和空格
        value=$(echo "$value" | tr -d ',' | xargs)
        if [[ -n "$value" && "$value" =~ ^[0-9]+$ ]]; then  # 确保是数字
            ((nat_counts[$value]++))
        fi
    done < "$temp_file"
    # 输出统计结果
    for i in {1..6}; do
        if [[ ${nat_counts[$i]} -gt 0 ]]; then
            LOG_INFO "NAT$i 类型数量: ${nat_counts[$i]}"
        fi
    done
    # 清理临时文件
    rm -f "$temp_file"
}

# 检查 dmesg 日志
function Error_dmesg() {
    Color_Yellow "正在检查 dmesg 日志..."
    if dmesg -T | grep "I/O error" | grep -q "sd"; then
        error_IO=$(dmesg -T | grep "I/O error" | tail -1)
        LOG_WARN "发现磁盘 I/O 异常："
        LOG_ERROR "$error_IO"
    else
        # echo -e "\033[32m未发现磁盘 I/O 错误。\033[0m"
        true
    fi

    if dmesg -T | grep -q "SYN"; then
        error_SYN=$(dmesg -T | grep "SYN" | tail -1)
        LOG_WARN "可能出现 SYN洪泛："
        LOG_ERROR "$error_SYN"
    else
        # echo -e "\033[32m未发现 SYN 洪泛。\033[0m"
        true
    fi

    if dmesg -T | grep -q "too many orphaned sockets"; then
        error_sockets=$(dmesg -T | grep "too many orphaned sockets" | tail -1)
        LOG_WARN "系统中存在过多的孤儿套接字："
        LOG_ERROR "$error_sockets"
    else
        # echo -e "\033[32m未发现过多的孤儿套接字。\033[0m"
        true
    fi

    if dmesg -T | grep -q "neighbour"; then
        error_neighbour=$(dmesg -T | grep "neighbour" | tail -1)
        LOG_WARN "路由表溢出："
        LOG_ERROR "$error_neighbour"
    else
        # echo -e "\033[32m未发现路由表溢出。\033[0m"
        true
    fi

    if dmesg -T | grep -q "HTB: quantum"; then
        quantum=$(dmesg -T | grep "HTB: quantum" | tail -1)
        LOG_WARN "quantum 值过大，可能会导致某些流量类别占用过多的带宽，影响其他流量的公平性："
        LOG_ERROR "$quantum"
    else
        true
    fi

    if dmesg -T | grep -q "oom-kill"; then
        oom=$(dmesg -T | grep "oom-kill" | tail -1)
        LOG_WARN "oom-kill, 内存不足："
        LOG_ERROR "$oom"
    else
        true
    fi
}

################################################################################
# 执行检查
################################################################################

echo -e "\033[33m\n\n开始检查 Guluserver 业务状态...\033[0m"
yum_repos
install_Toolset
Business_Cache
check_pod
nat_sum
Ping_check
Ping6_check
Error_dmesg
echo -e "\033[32m\n\n检查完成。\n\n\033[0m"