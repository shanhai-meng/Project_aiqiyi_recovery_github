该脚本主要用爱奇艺为定时检查跑量，自动更换端口

# 工作目录
aiqiyi_restore

# 跑量检测脚本(主程序)
Dispatching.sh

# 数据传输记录
dstat_send.txt

# 配置文件
/etc/aiqiyi_auto.conf

# 日志文件     
/logs/project.log

# 计划任务脚本
crontab.sh

# 项目环境准备
project_preparation.sh

文件服务器:
cd /usr/local/sandai/tw06d0006.onething.net/mengrun/
rm -rf /usr/local/sandai/tw06d0006.onething.net/mengrun/Project_aiqiyi_recovery
git clone https://gitee.com/shanhaimygitee/Project_aiqiyi_recovery.git
cd /usr/local/sandai/tw06d0006.onething.net/mengrun/Project_aiqiyi_recovery/Project_aiqiyi_recovery
sed -i 's/\r//' *.sh */*.sh
cd /usr/local/sandai/tw06d0006.onething.net/mengrun/Project_aiqiyi_recovery
rm -rf Project_aiqiyi_recovery.tar ; tar -cvf Project_aiqiyi_recovery.tar Project_aiqiyi_recovery/

实验机:  XRVDQAA8Q8HLQQYJ
rm -rf /Project_aiqiyi_recovery /tmp/Project_aiqiyi_recovery.tar; wget -O /tmp/Project_aiqiyi_recovery.tar http://tw06d0006.onething.net/mengrun/Project_aiqiyi_recovery/Project_aiqiyi_recovery.tar ; tar -xvf  /tmp/Project_aiqiyi_recovery.tar -C /


gitee 仓库
git config --global user.name "shanhai_mygitee"
git config --global user.email "14133090+shanhaimygitee@user.noreply.gitee.com"


github 仓库
git config --global user.name "ShanHai"
git config --global user.email "mengrun74@gmail.com"
