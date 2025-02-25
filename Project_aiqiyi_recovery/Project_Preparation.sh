#!/bin/bash
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf

# 启动前工作
if [ -d $TASK_SCRIPT ];then
    true
else 
    touch $send_record    #数据传输记录
    touch $project_log     #日志文件
    chmod +x $Crontab      #计划任务1
    chmod +x $TASK_SCRIPT  #跑量检测脚本
fi 
# 脚本声明
echo "          脚本使用须知："
echo "                  --该脚本每10分钟执行一次跑量探测"
echo "                  --当探测结果小于阈值时会自动修改端口"
echo "          配置文件："
echo "                  --工作目录：$work_directory"
echo "                  --日志信息：$project_log"
echo "                  --跑量记录：$send_record"
echo "          正在准备脚本环境"
echo "                                          —————请稍后"