##脚本配置文件
# 工作目录
export work_directory="/Project_aiqiyi_recovery"
# 跑量检测脚本(主程序)
export TASK_SCRIPT="/Project_aiqiyi_recovery/Dispatching.sh"
# 数据传输记录
export send_record="/Project_aiqiyi_recovery/dstat_send.txt"
# 配置文件
export project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
# 日志文件     
export project_log="/Project_aiqiyi_recovery/logs/project.log"
# 计划任务脚本
export Crontab="/Project_aiqiyi_recovery/crontab.sh"
# 项目环境准备
export prepare="/Project_aiqiyi_recovery/project_preparation.sh"


##复用功能
export Reuse_Function="/Project_aiqiyi_recovery/Script_library/Reuse-Function.sh"

##脚本库
# 检测
export IQlYl_CHECK="/Project_aiqiyi_recovery/Script_library/IQlYl-CHECK.sh"
# 新增data配置
export data_add_configuration="/Project_aiqiyi_recovery/Script_library/data-add_configuration.sh"
# 修改端口
export port_change="/Project_aiqiyi_recovery/Script_library/port-change.sh"
# export prot-change.old="/Project_aiqiyi_recovery/Script_library/prot-change.sh.old"
# 修改带宽
export SchedulingBandwidth_change="/Project_aiqiyi_recovery/Script_library/SchedulingBandwidth-change.sh"
# 清理缓存
export cache_clean="/Project_aiqiyi_recovery/Script_library/cache-clean.sh"
# 跨省/同省
export province_Non_same="/Project_aiqiyi_recovery/Script_library/province-Non_same.sh"
export province_same="/Project_aiqiyi_recovery/Script_library/province-same.sh"
# 删除ipv6设置
export ipv6_remove="/Project_aiqiyi_recovery/Script_library/ipv6-remove.sh"
# 挂载检测
export mount_check="/Project_aiqiyi_recovery/Script_library/mount-check.sh"
# 挂载重置
export mount_reset="/Project_aiqiyi_recovery/Script_library/mount-reset.sh"
# 端口扫描
export port_scanning="/Project_aiqiyi_recovery/Script_library/port-scanning.sh"