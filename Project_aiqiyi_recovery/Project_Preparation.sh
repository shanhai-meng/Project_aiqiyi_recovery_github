#!/bin/bash
# Description: 环境准备

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function



# 脚本声明
 Color_Green "          脚本使用须知："
 Color_Green "                         该脚本每10分钟执行一次跑量探测"
 Color_Green "                         当探测结果小于阈值时会自动修改端口"
 Color_Green "          配置文件："
 Color_Green "                         工作目录：$work_directory"
 Color_Green "                         日志信息：$project_log"
#  Color_Green "                         跑量记录：$send_record"
 Color_Green "          正在准备脚本环境"
 Color_Green "                                                          .....请稍后"


 # 启动前工作
touch $send_record    >&2 #数据传输记录
touch $project_log    >&2 #日志文件


scripts=($prepare $IQlYl_CHECK $port_change $data_add_configuration $SchedulingBandwidth_change $cache_clean $province_Non_same $province_same $ipv6_remove $mount_check $mount_reset $port_scanning)
# 环境检测
for i in "${scripts[@]}"; do
    if [ -f $i ];then
        true
    else 
        echo -e "$i脚本不存在，请确认脚本完整性\n" >&2
        exit 1
    fi
done

scripts2=($Crontab $TASK_SCRIPT $prepare $project_conf $Reuse_Function $IQlYl_CHECK $port_change $data_add_configuration $SchedulingBandwidth_change $cache_clean $province_Non_same $province_same $ipv6_remove $mount_check $mount_reset $port_scanning)
# 脚本权限
for i in "${scripts2[@]}";do 
    chmod +x $i  >&2
done