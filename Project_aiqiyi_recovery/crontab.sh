#!/bin/bash
# Description: 定时任务，定期执行脚本

# 变量定义（用户配置项）
project_conf="etc/conf.sh"
source $project_conf


# 定义要添加的 cron 任务
#CRON_JOB="1,30 * * * * $TASK_SCRIPT"
CRON_JOB="* * * * * sh $TASK_SCRIPT"
# 获取当前用户的 crontab 内容
# current_crontab=$(crontab -l >/dev/null)
current_crontab=$(crontab -l)
# 检查是否已经存在相同的任务
if ! echo "$current_crontab" | grep -q "$TASK_SCRIPT"; then
    # 添加新的 cron 任务
    #(echo "$current_crontab"; echo "$CRON_JOB") | crontab -
    printf "%s\n%s\n" "$current_crontab" "$CRON_JOB" | crontab -
    echo "计划任务已成功添加。"
else
    echo "计划任务已存在，未重复添加。"
fi
