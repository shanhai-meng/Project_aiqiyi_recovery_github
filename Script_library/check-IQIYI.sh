#!/bin/bash
################################################################################
# 内容概要：爱奇艺故障检测脚本
# 作者信息：KuangBo<kuangbo@onething.net>
# 更新时间：2024-07-04 14:00
################################################################################

################################################################################
# 日志输出方法定义
################################################################################
function LOG_INFO() {
  echo -e "\033[32m$(date +"%Y-%m-%d %H:%M:%S")\tINFO\t${1}\033[0m"
}

function LOG_WARN() {
  echo -e "\033[33m$(date +"%Y-%m-%d %H:%M:%S")\tWARN\t${1}\033[0m"
}

function LOG_ERROR() {
  echo -e "\033[31m$(date +"%Y-%m-%d %H:%M:%S")\tERROR\t${1}\033[0m"
}

################################################################################
# 变量定义（用户配置项）
################################################################################
# 步骤标识
step_flag=1

# 步骤数量
step_total=13

# dcache 配置文件
dcache_config="/opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml"

# dcache data 配置文件
dcache_data_config="/opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml"

# css 配置文件
css_config="/opt/soft/ipes/var/db/ipes/css-conf/cssconfig.json"

# css data 文件
css_data_config="/opt/soft/ipes/var/db/ipes/css-data/conf/cssconfig.json"

# 设备配置文件
device_config="/opt/soft/dcache/deviceid"

################################################################################
# 常量定义
################################################################################
# 域名列表
domain_list=(
    dcache.iqiyi.com
    stat-hcdn.iqiyi.com
    data.video.qiyi.com
    data.video.iqiyi.com
    policy.video.iqiyi.com
    hdb.iqiyi.com 
    pdata.video.qiyi.com
)

# 存活性服务检测列表
service_list=(
    dcache
    css
    kcp
    nginx
)

################################################################################
# 基础命令工具包检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行基础工具包安装，可能比较耗时，请等待..."
step_flag=$(( ${step_flag} + 1 ))

if [[ ! -e /usr/bin/jq || ! -e /usr/bin/xmllint || ! -e /usr/bin/tcping || ! -e /usr/bin/nc ]];then
    yum -y install jq libxml2 tcping > /dev/null 2>&1
    if [[ $? != 0 ]];then
        cd /etc/yum.repos.d/ && mkdir -p backup && mv CentOS* backup/ && wget -O /etc/yum.repos.d/ali.repo https://mirrors.aliyun.com/repo/Centos-7.repo && yum -y install jq libxml2 tcping nc
        if [[ $? != 0 ]];then
            LOG_ERROR "\t基础命令工具包安装失败，请手动安装或者检测 YUM 源配置，方法如下："
            LOG_ERROR "\t更新 YUM：cd /etc/yum.repos.d/ && mkdir -p backup && mv CentOS* backup/ && wget -O /etc/yum.repos.d/ali.repo https://mirrors.aliyun.com/repo/Centos-7.repo"
            LOG_ERROR "\t手动安装：yum -y install jq libxml2 tcping nc"
        fi
    fi
fi

################################################################################
# 获取节点基础信息
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始获取节点基础信息"
step_flag=$(( ${step_flag} + 1 ))
node_type="BKJ"

# 获取节点类型
if [[ $(cat /tmp/.efuse_sn  | grep XR | wc -l) ]];then
    node_type="x86"
fi

# 网络模式
runmode=$(cat /tmp/multidialstatus.json | jq '.runmode' | cut -d '"' -f 2)

# NAT 类型
nat_type=$(cat /etc/xyapp/galaxycheck/galaxycheck_speedtest_result.json | json_reformat | grep -a 'Nat类型' | awk -F '"' '{print $(NF-1)}')

# 当前的 NAT 信息
nat_info=$(/xyapp/system/miner.plugin-galaxycheck.ipk/tool/natclient | json_reformat)
nat_state=$(echo ${nat_info} | jq '.upnp_state')
if [[ ${nat_state} == 1 ]];then
    nat_type_now=$(echo ${nat_info} | jq '.upnp_udp_nat')
else
    nat_type_now=$(echo ${nat_info} | jq '.nat_type')
fi

# 线路数
line_number=$(cat /etc/xyapp/export_bandwidth.json | jq '.line_number')

# 单线带宽
per_line_bandwidth=$(cat /etc/xyapp/export_bandwidth.json | jq '.per_line_bandwidth')

# 获取线路信息
line_info=$(curl -s -m 10 myip.ipip.net)

# 判断数据是否正常
if [[ $(curl -s -m 10 myip.ipip.net | grep "IP" | wc -l) != 1 ]];then
    LOG_ERROR "\t获取节点网络信息失败，请手动检测是否能够正常获取，方法如下："
    LOG_ERROR "\t查看接口：curl -s -m 10 myip.ipip.net"
fi

# 检测结果
galaxycheck_result=$(cat /etc/xyapp/galaxycheck/galaxycheck_result.json | jq '.result[0].message[0]' | cut -d '"' -f 2)

# IP 地址
line_ip=$(echo ${line_info} | awk '{print $2}' | cut -d "：" -f 2)

# 省份
line_prov=$(echo ${line_info} | awk '{print $4}')

# 城市
line_city=$(echo ${line_info} | awk '{print $5}')

# 运营商
line_isp=$(echo ${line_info} | awk '{print $6}')

# 设备 ID
device_id=$(cat ${device_config})

LOG_INFO "\t设备编号：${device_id}"
LOG_INFO "\t节点类型：${node_type}"
LOG_INFO "\t网络模式：${runmode}"
LOG_INFO "\t周期 NAT：${nat_type}"
LOG_INFO "\t当前 NAT：${nat_type_now}"
LOG_INFO "\t线路数量：${line_number}"
LOG_INFO "\t单线带宽：${per_line_bandwidth}"
LOG_INFO "\t线路地址：${line_ip}"
LOG_INFO "\t线路省份：${line_prov}"
LOG_INFO "\t线路城市：${line_city}"
LOG_INFO "\t运营信息：${line_isp}"
LOG_INFO "\t历史异常：${galaxycheck_result}"


################################################################################
# 爱奇艺核心域名连通性检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行爱奇艺核心域名连通性检测"
step_flag=$(( ${step_flag} + 1 ))

# 爱奇艺核心域名连通性检测
for each_domain in ${domain_list[@]};do
    LOG_INFO "\t开始检测域名：${each_domain}"
    # 网络测试
    ping -i 0.3 -c 3 ${each_domain} > /dev/null 2>&1
    if [[ $? != 0 ]];then
        LOG_ERROR "\t域名 [${each_domain}] 网络连通性检测失败，请检测网络和 DNS 等配置，方法如下："
        LOG_ERROR "\t网络检测：ping -c 3 ${each_domain}"
        LOG_ERROR "\tDNS 查看：cat /etc/resolv.conf"
        LOG_ERROR "\tDNS 解析：nslookup ${each_domain}"
    fi
done

################################################################################
# CPU Load 检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行节点负载检测"
step_flag=$(( ${step_flag} + 1 ))

# CPU 负载
cpu_load=$(uptime | awk '{print $(NF-2)}' | cut -d "." -f 1)
# CPU 核数
cpu_cores=$(nproc)
# 判断负载是否超过 80%
if [ ${cpu_load} -gt $((cpu_cores * 80 / 100)) ]; then
    LOG_INFO "\tCPU 负载已经超过 80%，请注意排查服务是否异常，方法如下："
    LOG_INFO "\t查看负载：uptime"
else
    LOG_INFO "\t节点当前的负载率为：$(uptime | awk -F 'average:' '{print $2}')"
fi

################################################################################
# / 使用率检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行节点 / 分区使用率检测"
step_flag=$(( ${step_flag} + 1 ))

# / 分区使用率
root_useage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
# 判断 / 分区使用是否超过 90%
if [[ ${root_useage} -gt 90 ]];then
    LOG_ERROR "\t节点 / 分区使用率已经达到 ${root_useage}%，请及时排查清理，方法如下："
    LOG_ERROR "\t查看使用：df -h"
else
    LOG_INFO "\t节点 / 分区使用率为：${root_useage}%"
fi

################################################################################
# 挂载检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行挂载路径检测"
step_flag=$(( ${step_flag} + 1 ))

# 查看是否有挂载异常的路径
if [[ $(ls -lh / | grep "data" | grep "???" | wc -l) != 0 ]];then
    LOG_ERROR "\t有数据磁盘挂载异常，请手动查看挂载情况，方法如下："
    LOG_ERROR "\t查看挂载：ll -h / | grep 'data' | grep '???'"
    exit
fi

################################################################################
# 磁盘检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行磁盘可用性检测"
step_flag=$(( ${step_flag} + 1 ))

# 系统盘
system_device=$(lsblk | grep -v SWAP | grep -E "─sd|─nvme" | head -1 | cut -d "─" -f 2 | awk '{print $1}' | awk '{print substr($0, 1, length($0)-1)}')
if [[ ${system_device} == nvme* ]];then
    system_device=$(echo ${system_device} | awk -F 'p' '{print $1}')
fi
# 磁盘设备列表
device_list=$(lsblk | grep -v "SWAP" | grep -E "sd|nvme" | grep "disk" | awk '{print $1}')
# 磁盘数量
disk_num=0
# 异常 flag
disk_error_flag=0
# 信息输出
LOG_INFO "\t系统盘为：${system_device}"
# 磁盘挂载信息检测
for each_disk in ${device_list};do
    # 判断是否是系统盘，如果不是，就需要进行检测
    if [[ ${each_disk} != ${system_device} ]];then
        LOG_INFO "\t开始检测磁盘：${each_disk}"
        disk_num=$((disk_num + 1))
        
        # 统计磁盘分区
        lvm_count=$(lsblk /dev/${each_disk} | grep -v "MOUNTPOINT" | grep "lvm" | wc -l)
        if [[ ${lvm_count} -lt 2 ]];then
            disk_error_flag=1
            LOG_ERROR "\t磁盘 ${each_disk} 分区异常，至少需要存在 2 个 lvm 分区，请手动查看分区情况，方法如下："
            LOG_ERROR "\t查看挂载：lsblk /dev/${each_disk}"
            continue
        fi

        # 获取磁盘分区挂载信息
        lsblk /dev/${each_disk} | grep -v "MOUNTPOINT" | grep "lvm" | awk '{print $7}' | cat -n | while read -r linenum line; do  
            # 判断是否有挂载点
            if [[ ${line} != "" ]];then
                echo "TEST" > ${line}/echo.txt > /dev/null 2>&1
                if [[ $? != 0 ]];then
                    LOG_ERROR "\t磁盘 ${each_disk} 的挂载点 ${line} 无法写入文件，请手动写入测试，方法如下："
                    LOG_ERROR "\t手动写入：echo 'TEST' > ${line}/echo.txt"
                    continue
                fi
                rm -f ${line}/echo.txt > /dev/null 2>&1
            else
                LOG_ERROR "\t磁盘 ${each_disk} 存在没有挂载的分区，请手动查看挂载情况，方法如下："
                LOG_ERROR "\t查看挂载：lsblk /dev/${each_disk}"
            fi  
        done 
    fi
done

################################################################################
# 服务进程检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行服务进程检测"
step_flag=$(( ${step_flag} + 1 ))

# 服务进程检测
for each_service in ${service_list[@]};do
    online_days=$(ps -eo etime,cmd | grep "${each_service}" | grep -vE "grep|sh|worker" | awk '{print $1}' | awk -F '-' '{print $1}')
    if [[ ${online_days} == "" ]];then
        LOG_ERROR "\t${each_service}\t不在线"
    else
        if [[ ${online_days} == *":"* ]];then
            online_days=0
        fi
        online_time=$(ps -eo etime,cmd | grep "${each_service}" | grep -vE "grep|sh|worker" | awk '{print $1}' | awk -F '-' '{print $NF}')
        LOG_INFO "\t${each_service}\t已经在线 ${online_days} 天 ${online_time}"
    fi
done

################################################################################
# 服务端口检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行服务端口检测"
step_flag=$(( ${step_flag} + 1 ))

# 获取状态信息
export_status=$(curl -s http://127.0.0.1:8400/info?need=exportstatus)
if [[ $(echo ${export_status} | grep "isp" | wc -l) == 1 ]];then
    # 测通线路数量
    ip_num=$(echo ${export_status} | egrep -a -iwo "<ipnum>.*</ipnum>" | awk -F ">|<" '{print $3}')

    # 探测线路数量
    host_num=$(echo ${export_status} | egrep -a -iwo "<hostnum>.*</hostnum>" |awk -F ">|<" '{print $3}')
    if [[ ${ip_num} != ${host_num} ]];then
        LOG_ERROR "\t探测线路不等于通过线路：探测线路（${host_num}），测通线路（${ip_num}）" 
    fi

    # 电联要求端口必须通
    if [[ ${line_isp} != "移动" ]];then
        # IPV4
        ipv4_str=$(echo ${export_status} | egrep -a -iwo "<host>.*</host>")
        if [[ ${ipv4_str} != "" ]];then
            ipv4_hosts=$(echo ${ipv4_str} | sed -E 's/<host>([0-9\.]+):([0-9]+)<\/host>/\1:\2\n/g')
            ipv4_host_list=($ipv4_hosts)
            for ipv4_host in "${ipv4_host_list[@]}"; do
                LOG_INFO "\t开始检测接口连通性：${ipv4_host}"
                ipaddr=$(echo ${ipv4_host} | cut -d ":" -f 1)
                port=$(echo ${ipv4_host} | cut -d ":" -f 2)
                tcping ${ipaddr} ${port} > /dev/null 2>&1
                if [[ $? != 0 ]];then
                    LOG_ERROR "\t端口连通性检测失败：${ipv4_host}"
                fi
            done
        fi

        # IPV6
        ipv6_str=$(echo ${export_status} | egrep -a -iwo "<hostv6>.*</hostv6>")
        if [[ ${ipv6_str} != "" ]];then
            ipv6_hosts=$(echo ${ipv6_str} | sed -E 's/<hostv6>(\[[a-fA-F0-9:]+\]):([0-9]+)<\/hostv6>/\1:\2\n/g')  
            ipv6_host_list=($ipv6_hosts)
            for ipv6_host in "${ipv6_host_list[@]}"; do
                LOG_INFO "\t开始检测接口连通性：${ipv6_host}"
                ipv6addr=$(echo ${ipv6_host} | cut -d "]" -f 1 | cut -d "[" -f 2)
                port=$(echo ${ipv6_host} | cut -d "]" -f 2 | cut -d ":" -f 2)
                nc -vz ${ipv6addr} ${port} > /dev/null 2>&1
                if [[ $? != 0 ]];then
                    LOG_ERROR "\t端口连通性检测失败：${ipv6_host}"
                fi
            done
        fi

        # 如果两个都没有则会报错异常
        if [[ ${ipv4_str} == "" && ${ipv6_str} == "" ]];then
            LOG_ERROR "\t接口返回数据异常，请手动检测返回数据是否有监听地址，方法如下："
            LOG_ERROR "\t查看接口：curl http://127.0.0.1:8400/info?need=exportstatus"
        fi
    fi
else
    LOG_ERROR "\t接口返回数据异常，请手动检测返回数据是否有监听地址，方法如下："
    LOG_ERROR "\t查看接口：curl http://127.0.0.1:8400/info?need=exportstatus"
fi

################################################################################
# NAT 和基础线路检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行线路 NAT 配置检测"
step_flag=$(( ${step_flag} + 1 ))

# 线路信息
line=1
LOG_INFO "\t节点的线路总数为：${line_number}"
for line_status in $(cat /tmp/multidialstatus.json | jq '.multidial' | grep "errmsg" | awk '{print $NF}' | cut -d '"' -f 2); do
    LOG_INFO "\t开始对线路 ${line} 进行检测"
    if [[ ${line_status} != "ok" ]];then
        LOG_ERROR "\t线路 ${line} 检测异常，异常信息：${line_status}"
    fi
    line=$(($line+1))
done

# 获取线路周期检测异常
not_pass_line=$(cat /etc/xyapp/galaxycheck/galaxycheck_speedtest_result.json | jq '.["带宽不满足的线路"]')
if [[ ${not_pass_line} != null ]];then
    LOG_ERROR "\t带宽不满足的线路信息：${not_pass_line}"
fi

################################################################################
# 配置检测
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始进行 Dcache 配置文件检测"
step_flag=$(( ${step_flag} + 1 ))

LOG_INFO "\tDcache 主配置文件：\t${dcache_config}"
LOG_INFO "\tDcache Data 配置：\t${dcache_data_config}"
LOG_INFO "\tCSS 主配置文件：\t${css_config}"
LOG_INFO "\tCSS Data 配置：\t\t${css_data_config}"

# 语法检测
xmllint --noout ${dcache_config}
if [[ $? != 0 ]];then
    LOG_ERROR "\t配置文件存在语法错误：${dcache_config}"
fi

xmllint --noout ${dcache_data_config}
if [[ $? != 0 ]];then
    LOG_ERROR "\t配置文件存在语法错误：${dcache_data_config}"
fi

jq -e . < ${css_config} > /dev/null 2>&1
if [[ $? != 0 ]];then
    LOG_ERROR "\t配置文件存在语法错误：${css_config}"
fi

jq -e . < ${css_data_config} > /dev/null 2>&1
if [[ $? != 0 ]];then
    LOG_ERROR "\t配置文件存在语法错误：${css_data_config}"
fi

# Dcache 磁盘配置检测
dcache_config_disk_num=$(cat ${dcache_config} | grep 'ssddir' | wc -l)
dcache_data_config_disk_num=$(cat ${dcache_data_config} | grep 'ssddir' | wc -l)

if [[ ${dcache_config_disk_num} == 0 ]];then
    LOG_ERROR "\tDcache 主配置文件没有配置可用磁盘"
fi

if [[ ${dcache_data_config_disk_num} == 0 ]];then
    LOG_ERROR "\tDcache Data 配置文件没有配置可用磁盘"
fi

if [[ ${dcache_config_disk_num} != ${dcache_data_config_disk_num} ]];then
    LOG_ERROR "\tDcache（${dcache_config_disk_num}）主配置和 Data（${dcache_data_config_disk_num}）的配置磁盘数量不一致"
fi

# CSS 磁盘配置检测
css_config_disk_num=$(cat ${css_config} | grep 'diskpath' | wc -l)
css_config_file_disk_num=$(cat ${css_config} | jq '.storage.disknum')
css_data_config_disk_num=$(cat ${css_data_config} | grep 'diskpath' | wc -l)
css_data_config_file_disk_num=$(cat ${css_data_config} | jq '.storage.disknum')

if [[ ${css_config_disk_num} == 0 ]];then
    LOG_ERROR "\tCSS 主配置文件没有配置可用磁盘"
fi

if [[ ${css_data_config_disk_num} == 0 ]];then
    LOG_ERROR "\tCSS Data 配置文件没有配置可用磁盘"
fi

if [[ ${css_config_disk_num} != ${css_data_config_disk_num} ]];then
    LOG_ERROR "\tCSS（${css_config_disk_num}）主配置和 Data（${css_data_config_disk_num}）的配置磁盘数量不一致"
fi

if [[ ${css_config_disk_num} != ${css_config_file_disk_num} ]];then
    LOG_ERROR "\tCSS 主配置中配置的磁盘数量（${css_config_disk_num}）和实际配置的磁盘路径数量（${css_config_file_disk_num}）不一致"
fi

if [[ ${css_data_config_disk_num} != ${css_data_config_file_disk_num} ]];then
    LOG_ERROR "\tCSS Data 配置中配置的磁盘数量（${css_data_config_disk_num}）和实际配置的磁盘路径数量（${css_data_config_file_disk_num}）不一致"
fi

# 和实际磁盘数量比较
if [[ ${disk_num} != ${dcache_config_disk_num} ]];then
    LOG_ERROR "\tDcache 主配置中配置的磁盘数量（${css_config_disk_num}）和实际磁盘数量（${disk_num}）不一致"
fi

if [[ ${disk_num} != ${css_config_disk_num} ]];then
    LOG_ERROR "\tCSS 主配置中配置的磁盘数量（${css_config_disk_num}）和实际磁盘数量（${disk_num}）不一致"
fi

# 带宽检测
device_bandwidth=$(( $(cat /etc/xyapp/export_bandwidth.json | awk -F ':' '{print $2}' | awk -F ',' '{print $1}') * $(cat /etc/xyapp/export_bandwidth.json | awk -F ':' '{print $3}' | awk -F '}' '{print $1}') ))
config_bandwidth=$(( $(cat ${dcache_config} | grep 'bandwidth' | awk -F '>' '{print $2}' | awk -F '<' '{print $1}') * 8 ))

if [[ ${config_bandwidth} == 0 ]];then
    LOG_ERROR "\tDcache 主配置中配置带宽为 0，不合法，推荐修改为：$(( ${device_bandwidth}/8 ))"
fi

if [[ ${config_bandwidth} -gt ${device_bandwidth} ]];then
    LOG_ERROR "\tDcache 主配置中配置带宽大于设备上报带宽，不合法，推荐修改为：$(( ${device_bandwidth}/8 ))"
fi


################################################################################
# ID 是否加白
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始检测 ID 是否加白"
step_flag=$(( ${step_flag} + 1 ))

# 请求
start_time=$(date -d '-60 minutes' +%s)
end_time=$(date +%s)
response=$(curl -s  GET "https://dcache.iqiyi.com/api/flow?deviceid=${device_id}&endtime=${end_time}&format=json&starttime=${start_time}" --user onething:Ox_2018) > /dev/null 2>&1

if [[ $(echo ${response} | grep '"code":1010' | wc -l) != 0 ]];then
    LOG_ERROR "\t设备 ID（${device_id}）不在爱奇艺的白名单之中"
fi

################################################################################
# 爱奇艺归因系统问题排查
################################################################################
LOG_WARN "[${step_flag}/${step_total}]\t开始检测爱奇艺归因系统异常数据"
step_flag=$(( ${step_flag} + 1 ))

# 检查归因系统
response=$(curl -s 'https://dcache.iqiyi.com/api/error_dcache/' \
    --header 'Authorization: Basic b25ldGhpbmc6T3hfMjAxOA==' \
    --header 'Cookie: csrftoken=tHdq42xbvgUSrH46ZBinK7ngzfEuKKs9O7c6k4rYigwdHwSlhlYMEtglQp6yvIdE' \
    --header 'User-Agent: Apifox/1.0.0 (https://apifox.com)' \
    --header 'Content-Type: charset=UTF-8' | iconv -f GB2312 -t utf-8 | grep ${device_id}) > /dev/null 2>&1

if [[ ${response} != "" ]];then
    LOG_ERROR "\t异常信息：${response}"
fi

