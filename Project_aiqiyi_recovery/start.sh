#!/bin/bash

## 跑量恢复脚本启动文件

# 启动前工作
sed -i 's/\r//' ./*
sed -i 's/\r//' ./etc/aiqiyi_auto.conf

if [ /aiqiyi_restore -d ];then
    exit 0
else
    mkdir /aiqiyi_restore   #工作目录
fi 

source ./etc/aiqiyi_auto.conf

if [ /aiqiyi_restore -d ];then
    exit 0
else
    mv /tmp/Project_aiqiyi_recovery/* $work_directory
fi 

chmod +x $prepare
bash $prepare

# 程序启动
bash $crontab1
bash $TASK_SCRIPT



