#!/bin/bash
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $config_file

sed -i 's/\r//' /Project_aiqiyi_recovery/*   
sed -i 's/\r//' /Project_aiqiyi_recovery/etc/* 
## 跑量恢复脚本启动文件

# 启动前工作

if [ -d "/Project_aiqiyi_recovery"  ];then
    echo "工作目录已经存在"
else
    echo "工作目录不存在"
fi

project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $config_file

chmod +x $prepare
bash $prepare

# 程序启动
bash $crontab1
bash $TASK_SCRIPT