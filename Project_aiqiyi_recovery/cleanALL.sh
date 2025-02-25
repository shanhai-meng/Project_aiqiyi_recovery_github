#!/bin/bash
#清理环境
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf

# 定义要删除的关键词
keyword="Project_aiqiyi_recovery"
# 将当前的 crontab 内容导出到一个临时文件
crontab -l > /tmp/current_crontab.txt
# 使用 sed 删除包含关键词的行
sed -i "/$keyword/d" /tmp/current_crontab.txt
# 将修改后的内容重新加载到 crontab
crontab /tmp/current_crontab.txt
# 清理临时文件
rm /tmp/current_crontab.txt
echo "计划任务已成功删除。"