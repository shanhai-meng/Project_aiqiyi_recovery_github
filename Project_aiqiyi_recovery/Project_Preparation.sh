#!/bin/bash
# Description: 环境准备

# 变量定义（用户配置项）
project_conf="etc/conf.sh"
Reuse_Function="Script_library/Reuse-Function.sh"
source $project_conf
source $Reuse_Function



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
 Color_Green "          脚本使用须知："
 Color_Green "                         该脚本每10分钟执行一次跑量探测"
 Color_Green "                         当探测结果小于阈值时会自动修改端口"
 Color_Green "          配置文件："
 Color_Green "                         工作目录：$work_directory"
 Color_Green "                         日志信息：$project_log"
 Color_Green "                         跑量记录：$send_record"
 Color_Green "          正在准备脚本环境"
 Color_Green "                                                          .....请稍后"