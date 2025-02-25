#!/bin/bash
# Description: 跑量恢复脚本启动文件

# 项目配置
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf

# cd /etc/yum.repos.d/
# mkdir backup > /dev/null 
# mv -f CentOS-* backup/
# wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null
# yum -y install dos2unix > /dev/null 2>&1
# cd $work_directory
# dos2unix start.sh > /dev/null 2>&1

# sed -i 's/\r//' /Project_aiqiyi_recovery/start.sh
# sed -i 's/\r//' /Project_aiqiyi_recovery/Dispatching.sh
# sed -i 's/\r//' /Project_aiqiyi_recovery/crontab.sh
# sed -i 's/\r//' /Project_aiqiyi_recovery/Project_Preparation.sh
# sed -i 's/\r//' /Project_aiqiyi_recovery/etc/conf.sh



# 启动前工作
if [ -d "/Project_aiqiyi_recovery"  ];then
    echo "工作目录已经存在"
else
    echo "工作目录不存在"
fi
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
chmod +x $prepare
bash $prepare
# 程序启动
bash $Crontab
bash $TASK_SCRIPT