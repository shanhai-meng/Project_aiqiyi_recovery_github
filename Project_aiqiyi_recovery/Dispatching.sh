#!/bin/bash
################################################################################
# 内容概要：爱奇艺故障恢复脚本
# 作者信息：MengRun<MengRun@onething.net>
# 更新时间：2025-02-26 1:00
# 描述信息: 该脚本主要用爱奇艺为定时检查跑量，自动更换端口
################################################################################



################################################################################
# 日志输出方法定义
################################################################################
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
# 变量定义（用户配置项）
################################################################################
# 项目配置
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
prot_change="/Script_library/prot-change.sh"
source $project_conf

# env
datenew=$(date +"%Y-%m-%d %H:%M:%S")


################################################################################
# 跑量恢复模块
################################################################################
# 更换端口模块
# function iqiyi_change_prot() {
# 		   wget -O /tmp/iqiyi_change_prot.sh http://tw06d0006.onething.net/mengrun/iqiyi_change_prot.sh && sh /tmp/iqiyi_change_prot.sh
# }

# 检测跑量模块
function send_detection() {
    ## 收集10s内上传数据量计算均值
    # 运行 dstat 命令并提取 send 列的数据
    number=10
    while [ $number -gt 0 ]; do
        dstat -n 1 1 | column  -t | awk '{send = $2} END {print send}' >> $send_record
        number=$((number - 1))
    done
    # 消除单位并转换为数字
    sed -i 's/k/000/' $send_record
    sed -i 's/M/000000/' $send_record
    # 读取数据并计算均值
    sum=0
    count=0
    while read -r line; do
        sum=$((sum + line))
        count=$((count + 1))
    done < $send_record

    # 计算上传数据量send
    average=$((sum / count))
    if [ $average -gt 10000000 ];then
        average2=$(($average/1000000))
    # 输出均值
        LOG_INFO "当前上传数据量均值为：$average2 M"
        # echo -e "$datenew\t当前上传数据量均值为：$average2 M"
    else
        average2=$(($average/1000))
        LOG_ERROR "当前上传数据量均值为：$average2 k"
        # echo -e "$datenew\t当前上传数据量均值为：$average2 k"
    fi
    # 当上传数据量小于5MB/s时更换端口
    if [ $average -le 5000000 ];then
         LOG_WARN "当前上传数据量小于5MB/s,尝试更换端口中..."
		# echo -e "$datenew\t当前小于5MB/s,尝试更换端口中..."
		bash $prot_change
	else
        LOG_INFO "业务正常运行中!"
		# echo -e "$datenew\t业务正常运行中!"
	fi
    # 清理临时文件
    rm $send_record
}

# 日志清理
function clean_log() {
    log_lines=$(wc -l < "$project_log")
    # 判断日志条数是否大于 50
    if [ "$log_lines" -ge 50 ]; then
        # 使用 tail 保留最后 50 行，并覆盖原文件
        tail -n 50 "$project_log" > "$project_log.tmp" && mv -f "$project_log.tmp" "$project_log"
    else
        true
    fi
}


send_detection >> $project_log
clean_log