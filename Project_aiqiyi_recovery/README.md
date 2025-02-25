该脚本主要用爱奇艺为定时检查跑量，自动更换端口

# 工作目录
# /aiqiyi_restore

# 跑量检测脚本(主程序)
# /aiqiyi_restore/Dispatching.sh

# 数据传输记录
# aiqiyi_restore/dstat_send.txt  

# 配置文件
# /aiqiyi_restore/etc/aiqiyi_auto.conf

# 日志文件     
# /aiqiyi_restore/logs/project.log

# 计划任务脚本
# /aiqiyi_restore/crontab.sh

# 项目环境准备
# /aiqiyi_restore/Project_Preparation.sh

# 文件服务器
rm -rf aiqiyi_project.sh  crontab.sh Project_Preparation.sh start.sh
sed -i 's/\r//' Dispatching.sh crontab.sh Project_Preparation.sh start.sh etc/conf.sh  cleanALL.sh
rm -rf Project_aiqiyi_recovery.tar ; tar -cvf Project_aiqiyi_recovery.tar Project_aiqiyi_recovery/

# 实验机  XRVDK7AZX6423NJ1
rm -rf /Project_aiqiyi_recovery /tmp/Project_aiqiyi_recovery.tar; wget -O /tmp/Project_aiqiyi_recovery.tar http://tw06d0006.onething.net/mengrun/Project_aiqiyi_recovery/Project_aiqiyi_recovery.tar ; tar -xvf  /tmp/Project_aiqiyi_recovery.tar -C /
sed -i 's/\r//' Dispatching.sh crontab.sh Project_Preparation.sh start.sh etc/conf.sh  cleanALL.sh