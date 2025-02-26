#!/bin/bash
# Description: 跑量恢复脚本启动文件

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

chmod +x $prepare
bash $prepare
# 程序启动
bash $Crontab 
bash $TASK_SCRIPT