#!/bin/bash
# Description: 清理环境

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf

# 清理计划任务
function clean_crontab {
    keyword="Project_aiqiyi_recovery"
    crontab -l > /tmp/current_crontab.txt
    sed -i "/$keyword/d" /tmp/current_crontab.txt
    crontab /tmp/current_crontab.txt
    rm /tmp/current_crontab.txt
    echo "计划任务已成功删除。"
}

clean_crontab