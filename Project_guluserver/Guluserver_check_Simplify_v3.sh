#!/bin/bash
################################################################################
# 内容概要：Guluserver故障检测脚本
# 作者信息：Mengrun<Mengrun@onething.net>
# 更新时间：2025-02-28 2:00
################################################################################

################################################################################
# 日志输出方法定义
################################################################################

function Color_Red() {
  echo -e "\033[31m\t${1}\033[0m"
}
function Color_Green() {
  echo -e "\033[32m\t${1}\033[0m"
}
function Color_Yellow() {
  echo -e "\033[33m\t${1}\033[0m"
}

function LOG_INFO() {
  echo -e "\033[32m\tINFO\t\t${1}\033[0m"
}

function LOG_WARN() {
  echo -e "\033[33m\tWARN\t\t${1}\033[0m"
}

function LOG_ERROR() {
  echo -e "\033[31m\tERROR\t\t${1}\033[0m"
}
################################################################################
# 常量定义
################################################################################

datenew=$(date +"%Y-%m-%d %H:%M:%S")

# 步骤标识
step_flag=1

# 步骤数量
step_total=11

# appid库
declare -A codes=(
    ["G3"]="58023b6c2d82ec09adec3197e05a9861"
    ["T6"]="d7b61a08735a8bdcc8fa4174a1f5eb02"
    ["Bsp2"]="718c9bebd826301e87a05f25b9e4e9c5"
    ["J"]="321074c78ca95aaaeb4dfaff4f9a06d3"
    ["D2"]="97eee0abc928279a49e9d227fd700cbd"
    ["superD"]="9440474f3cca2494e1e6bf9e0bfdb510"
    ["D"]="52d531d3ea193a292485d06517b4b5fd"
    ["superK"]="097df03fdf4d190dc6d609c67096b56e"
    ["H"]="f8f669993ab0c26a1ae5541cdf61bd0c"
    ["C"]="0e171d55cdd88629e0af4726df2da5f2"
    ["S"]="0b9d1fd5245667b3aaf766b83a44d294"
    ["S2"]="888c6a5d4fd1b8213a8415eff8a3dccb"
    ["G3-同省"]="8a0bb653d96557a938b76f71668b2ffd"
    ["U1"]="b243ed684e9d0877b25a15dda0d5bbbf"
    ["G2"]="5f2b03a4572d91cda6138685eb80206f"
    ["L"]="24b2f473204147a85d41e163ee286853"
    ["Bsp"]="8ac2f536cf955ae6a0fa510135bf2880"
    ["superV"]="a562945659d73e5584b8cf54a23a0470"
    ["G业务"]="0056ee29b5bdfffe122a3a63dd68e2d0"
    ["X3_J"]="964620abdf65a7ad872f8e11d715c33b"
    ["X3_G3"]="09c81a1980598333aaa2ebce34b0b154"
    ["X3_T6"]="9c390e78ea665588c1645cb31f09e254"
    ["X3_Bsp2"]="1aaef573a81ec7bbd7bc1ae7194e02f9"
    ["X3_Bsp"]="c8264141db6cd976e634d329198c2c5f"
    ["X3_J3"]="a91b445ca891e2b540e6b202137db691"
    ["X5_S"]="f5ea83e843e41c82ac08c17af90a72ad"
    ["X5_superK"]="b74fcecd6eadaf40677f188dbb589bce"
    ["X5_G2"]="4141f150bf76bae46d1c50c45bf68b0d"
    ["X5_D"]="9202e37536cb345617aa3ea55e3bd0e5"
    ["X5_H"]="5720102dfa9599343560eaa7d62701b7"
    ["X5_G5"]="29ade6d2bf1c7dc78128934323052750"
    ["X5_SV"]="c011c3027d03ffa922bb79a12269de28"
    ["专线Y"]="7eb1e6696c695f7ab576d13a868f4ce4"
    ["V5"]="d12f63d4482078fe5c34bd176b240128"
    ["F"]="8963c0b2c29773831101b5553c5ee91b"
    ["F2"]="2698d6c20affd188754ca34f17f43918"
    ["P"]="44ff4cb7e5e5ffa4d33e8d5fe87fd9cd"
    ["J3"]="d6187415d9de4356ba063b921b150bbb"
    ["J2"]="18f61ce0c5b622222b5e34b00c52be38"
    ["H3"]="a4613fda8164782b22a69df21a8ac288"
    ["H2"]="834fadcf6171005fcbdf1c8a8a3f552f"
    ["H4"]="316de54a7c46b34d3acc37443251bf1d"
    ["专线S"]="285a46756871c78d4c5d1c420e89c6e7"
    ["superL"]="ce05fb87e9eac80d8f034337126b90fe"
    ["superK"]="097df03fdf4d190dc6d609c67096b56e"
    ["superS"]="5a1c433698a67c227fe60bb41f80c2dc"
    ["T6-N4"]="e4068133ea57e45a5026eae948b9854b"
    ["专线T"]="e29615fd16484557f093b9734e0536a1"
    ["T3"]="af305987e70a37117ddb04d92f6351f2"
    ["专线B"]="87629f1452ff476678e612fa2a0dc6e8"
    ["B1网盘"]="c68ced7efbe9cce8d48b3f095a81c4fa"
    ["B网盘"]="984017bcbfc37757a79ff41324d54008"
    ["E"]="0f44b5cb744447b3f7c487c38a650c98"
    ["E2"]="5432cdde6bfa3b82e73f8a6e7c0e5ce9"
    ["B2网盘"]="497d95ff5a1b9cbc72863bf9573aaa2d"
    ["B"]="9a63b1461a4e917bc5b48859a6c9feae"
    ["专线Z"]="47a75dd810bd6897f5dc4117e1c941ef"
    ["Y"]="0625191cb1329380f8e5f32923b88876"
    ["A"]="17cf18f72273a24d6bd30cf5e1cef3d2"
    ["superA"]="6318d38af49a9ec3108679f67102bfae"
    ["X1"]="b1f0111f347e3aa0cf16055b64a4bba8"
    ["专线D"]="e04b3f172e158adbfe0c2e8dc3ecf326"
    ["X"]="428e97a47a1f6944e271244d0bb87166"
    ["M"]="266a5befa88c407407008ee134e46a7c"
    ["superM"]="b69602f5cc120ad037fef0b78629cda6"
    ["B2"]="6a48c2eb311d021249fd9dd10f8c2e64"
    ["Bop"]="f69c8d2e7f8cf8b45ea3d43f52277b95"
    ["Z"]="18e5e85d32df5a474f509aa86bcf0015"
    ["Z1"]="a57385080173fe67c89589f399b60422"
    ["Z2"]="302d5da755599795dc6fcf90220"
    ["N4"]="ea10fd5f2af6f0757398b071e6ea1976"
    ["B8"]="c827319d158fa3adc69d61a98ac33fe1"
    ["G2-N4"]="dec7d25c8f4bf02acec2b23dfd5860c9"
    ["百度网盘"]="c68ced7efbe9cce8d48b3f095a81c4fa310028120"
)

################################################################################
# 函数定义
################################################################################

# 加载特效(动态显示 .、..、...)
function Dynamic() {
    local message="$1"  # 获取传递的字符串
    interval=0.5
    for dots in "." ".." "..."; do
        echo -ne "\r${message} $dots"  # 将动态点加到字符串后面
        sleep "$interval"
    done
}

# 更新 YUM 源
function yum_repos() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始进行基础工具包安装，可能比较耗时，请等待..."
    step_flag=$(( ${step_flag} + 1 ))
    # Color_Yellow "开始备份 YUM 源..."
    cd /etc/yum.repos.d/ 
    mkdir backup  > /dev/null 2>&1
    mv CentOS-* backup/  backup  > /dev/null 2>&1
    wget -O --timeout=3 /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null 2>&1
    cd - > /dev/null 2>&1

    # 安装必要的工具
    yum -y install jq >/dev/null 2>&1
}

# 获取基础信息
function Basic_Information() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始获取节点基础信息"
    step_flag=$(( ${step_flag} + 1 ))
    node_type="BKJ"

    # sn
    sn1=$(cat /tmp/.efuse_sn)

    # 主机名
    hostname1=$(cat /etc/xyapp/hostname)

    # 获取节点类型
    if [[ $(cat /tmp/.efuse_sn  | grep XR | wc -l) == 1 ]];then
        node_type="x86"
    fi

    # 网络模式
    runmode=$(cat /tmp/multidialstatus.json | jq '.runmode' | cut -d '"' -f 2)

    # 线路数
    line_number=$(cat /etc/xyapp/export_bandwidth.json | jq '.line_number')

    # 单线带宽
    per_line_bandwidth=$(cat /etc/xyapp/export_bandwidth.json | jq '.per_line_bandwidth')

    # 矫正线路数
    corrective_circuit=$(cat /etc/xyapp/export_bandwidth_corrected.json | jq '.line_number')

    # 矫正带宽
    corrective_bandwidth=$(cat /etc/xyapp/export_bandwidth_corrected.json | jq '.per_line_bandwidth')

    # 获取线路信息
    curl -s myip.ipip.net > /tmp/line_info.txt
    line_info='/tmp/line_info.txt'

    # 判断数据是否正常
    if [[ $(cat /tmp/line_info.txt | wc -l) != 1 ]];then
        LOG_ERROR "\t获取节点网络信息失败，请手动检测是否能够正常获取，方法如下："
        LOG_ERROR "\t查看接口：curl myip.ipip.net"
    fi

    # IP 地址
    line_ip=$(awk '{print $2}' $line_info | cut -d "：" -f 2)

    # 省份
    line_prov=$(awk '{print $4}' $line_info)

    # 城市
    line_city=$(awk '{print $5}' $line_info)

    # 运营商
    line_isp=$(awk '{print $6}' $line_info)

    # XYB_appid
    XYB_appid=$(cat /xyapp/system/plugin-mdata/instanceNodeInfo.json | awk -F\{ '{print $2}' | awk -F\} '{print $2}')

    # 业务情况
    Business_file='/tmp/Business.txt'
    if [[ $(cat /tmp/.efuse_sn  | grep XR | wc -l) ]];then
        /xyapp/system/miner.plugin-activation.ipk/tools/recruit_tools -p show > $Business_file 2>&1
    fi
    Business_name=$(awk 'NR==1{print $2}' $Business_file)
    Business_appid=$(awk 'NR==2{print $2}' $Business_file)
    Business_status=$(awk 'NR==3{print $2}' $Business_file)
    
    # 业务切入时间
    Business_time=$(cat /etc/xyapp/recruitResult.json | python -m json.tool | grep ts | awk '{print $2}' | tr -d ,)
    Business_time=$(date -d @$Business_time "+%Y-%m-%d %H:%M:%S")
    
    LOG_INFO "\tSN：${sn1}"
    LOG_INFO "\t主机名：${hostname1}"
    LOG_INFO "\t节点类型：${node_type}"
    LOG_INFO "\t网络模式：${runmode}"
    LOG_INFO "\t承诺线路数量：\033[93m${line_number}\033[0m"
    LOG_INFO "\t承诺带宽：\033[93m${per_line_bandwidth}\033[0m"
    LOG_INFO "\t矫正线路数量：\033[93m${corrective_circuit}\033[0m" 
    LOG_INFO "\t矫正带宽：\033[93m${corrective_bandwidth}\033[0m" 
    LOG_INFO "\t线路地址：${line_ip}"
    LOG_INFO "\t线路省份：${line_prov}"
    LOG_INFO "\t线路城市：${line_city}"
    LOG_INFO "\t运营信息：${line_isp}"
    LOG_INFO "\t业务切入时间：${Business_time}"

    # 获取业务名称
    if [ -e /xyapp/system/miner.plugin-activation.ipk/tools/recruit_tools ];then
        found=false  # 用于标记是否找到匹配的业务名称
        for key in "${!codes[@]}"; do
            if [[ "${codes[$key]}" == "$Business_appid" ]]; then
                LOG_INFO "\t业务名称：${key}"  # 输出找到的业务名称
                found=true  # 标记为找到
                break  # 找到后退出循环
            fi
        done
    else
        search_value=$(echo "$XYB_appid" | tr -d '\001\003')
        found=false  # 用于标记是否找到匹配的业务名称
        for key in "${!codes[@]}"; do
            if [[ "${codes[$key]}" == "$search_value" ]]; then
                LOG_INFO "\t业务名称：${key}"  # 输出找到的业务名称 
                found=true  # 标记为找到
                break  # 找到后退出循环
            fi
        done
    fi

    # 获取appid
    if [[ -e /xyapp/system/miner.plugin-activation.ipk/tools/recruit_tools ]];then
        LOG_INFO "\t业务APPID：${Business_appid}"
    else
        LOG_INFO "\t业务APPID：${XYB_appid}"
    fi

    # 获取业务状态
    LOG_INFO "\t业务状态：${Business_status}"
}

# 查看磁盘iops
function disk_IOPS() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始查看磁盘IOPS"
    step_flag=$(( ${step_flag} + 1 ))

    # 获取磁盘IOPS
    jq -r '.disk_info[] | select(.rand_read_iops) | "\(.name): \(.rand_read_iops)"' /etc/xyapp/disk_info.json  > /tmp/iops.txt
    while read -r line; do
        LOG_INFO "\t${line}"
    done < /tmp/iops.txt
    
    rm -f /tmp/iops.txt
}


# 查看实例缓存情况
function Business_Cache() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始查看缓存点情况"
    step_flag=$(( ${step_flag} + 1 ))

    # 初始化关联数组
    declare -A counters
    for i in {0..90..10}; do
        counters["${i}-$(($i + 10))%"]=0  # 正确生成区间范围
    done

    # 提取使用率数据并保存到文件
    df -Th | grep storage | grep -v _vg_lv | awk '{print $6}' | awk -F'%' '{print $1}' > usage_data.txt

    # 定义统计函数
    count_usage() {
        local usage=$(( $1 ))  # 强制转换为整数
        if (( usage >= 0 && usage <= 10 )); then
            ((counters["0-10%"]++))
        elif (( usage > 10 && usage <= 20 )); then
            ((counters["10-20%"]++))
        elif (( usage > 20 && usage <= 30 )); then
            ((counters["20-30%"]++))
        elif (( usage > 30 && usage <= 40 )); then
            ((counters["30-40%"]++))
        elif (( usage > 40 && usage <= 50 )); then
            ((counters["40-50%"]++))
        elif (( usage > 50 && usage <= 60 )); then
            ((counters["50-60%"]++))
        elif (( usage > 60 && usage <= 70 )); then
            ((counters["60-70%"]++))
        elif (( usage > 70 && usage <= 80 )); then
            ((counters["70-80%"]++))
        elif (( usage > 80 && usage <= 90 )); then
            ((counters["80-90%"]++))
        elif (( usage > 90 && usage <= 100 )); then
            ((counters["90-100%"]++))
        fi
    }

    # 从文件中读取使用率并统计
    while read -r use_percent; do
        count_usage "$use_percent"
    done < usage_data.txt

    # 输出统计结果
    for range in "${!counters[@]}"; do
        if [[ ${counters[$range]} -gt 0 ]]; then  # 只输出实例数不为 0 的区间
            LOG_INFO "\t有 ${counters[$range]} 个挂载点缓存在 $range"
        fi
    done
    rm -rf usage_data.txt
}

# 检查实例数
function check_pod() {
    if [[ $(docker ps | grep 'gulu' |wc -l) != 0 ]];then
        LOG_WARN "[${step_flag}/${step_total}]\t开始查看实例数情况"
        step_flag=$(( ${step_flag} + 1 ))

        Theoretical_sum=$(jq -r '(.per_line_bandwidth * (.line_number / 50))' /etc/xyapp/export_bandwidth_corrected.json)
        Practical_sum=$(lvs | grep -vE "LSize|_vg_lv" | wc -l)
        Pod_sum=$(docker ps | grep -vE "CONTAINER|network" | wc -l)
        LOG_INFO "\t理论实例数：$Theoretical_sum"
        LOG_INFO "\t当前实例数：$Pod_sum"
        # LOG_INFO "存储卷数量：\t\t$Practical_sum"
    fi
}

# 检查 Ping 连通性
function Ping_check() {
    networksum=$(docker ps | grep network | wc -l)
    if  [ $networksum -eq 0 ];then
        LOG_WARN "[${step_flag}/${step_total}]\t开始测试主机 IPv4 连通性..."
        step_flag=$(( ${step_flag} + 1 ))

        ping -c 1 www.baidu.com > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            LOG_INFO "\t主机 IPv4 连通性测试成功。"
        else
            LOG_ERROR "\t主机 IPv4 连通性测试失败。"
        fi
    else
        # 获取所有符合条件的容器 ID
        container_ids=$(docker ps | grep network | awk '{print $1}')
        # 将容器 ID 转换为数组
        readarray -t containers <<< "$container_ids"
        # 获取容器数量
        num_containers=${#containers[@]}
        # 随机选择一个容器 ID
        random_index=$((RANDOM % num_containers))
        podid=${containers[$random_index]}
        # 输出开始测试的容器 ID
        LOG_WARN "[${step_flag}/${step_total}]\t开始随机测试业务容器 IPv4 连通性..."
        step_flag=$(( ${step_flag} + 1 ))
        # 测试 IPv4 连通性
        if docker exec "$podid" sh -c "ping -c 1 www.baidu.com" > /dev/null 2>&1; then
            LOG_INFO "\t随机测试容器 IPv4 连通性测试成功。"
        else
            LOG_ERROR "\t随机测试容器 IPv4 连通性测试失败。"
        fi
    fi
}

function Ping6_check() {
    networksum=$(docker ps | grep network | wc -l)
    if  [ $networksum -eq 0 ];then
        LOG_WARN "[${step_flag}/${step_total}]\t开始测试主机 IPv6 连通性..."
        step_flag=$(( ${step_flag} + 1 ))

        ping6 -c 1 www.baidu.com > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            LOG_INFO "\t主机 IPv6 连通性测试成功。"
        else
            LOG_ERROR "\t主机 IPv6 连通性测试失败。"
        fi
    else
        container_ids=$(docker ps | grep network | awk '{print $1}')
        # 将容器 ID 转换为数组
        readarray -t containers <<< "$container_ids"
        # 获取容器数量
        num_containers=${#containers[@]}
        # 随机选择一个容器 ID
        random_index=$((RANDOM % num_containers))
        podid=${containers[$random_index]}
        # 输出开始测试的容器 ID
        LOG_WARN "[${step_flag}/${step_total}]\t开始随机测试业务容器 IPv6 连通性..."
        step_flag=$(( ${step_flag} + 1 ))
        # 测试 IPv6 连通性
        if docker exec "$podid" sh -c "ping6 -c 1 www.baidu.com" > /dev/null 2>&1; then
            LOG_INFO "\t随机测试容器 IPv6 连通性测试成功。"
        else
            LOG_ERROR "\t随机测试容器 IPv6 连通性测试失败。（该结果为随机抽取network测试，不代表全部容器）"
        fi
    fi
}

# 统计 NAT 类型
function nat_sum() {
    temp_file="/tmp/udp_nat_values.txt"
    # 提示开始判断 NAT 类型
    LOG_WARN "[${step_flag}/${step_total}]\t开始判断 NAT 类型"
    step_flag=$(( ${step_flag} + 1 ))

    # 从 JSON 文件中提取 udp_nat 的值并保存到临时文件
    cat /tmp/net_link_prober.json | python -m json.tool | grep -w "udp_nat" | awk -F': ' '{print $2}' > "$temp_file"
    # 检查临时文件是否存在
    if [ ! -f "$temp_file" ]; then
        LOG_ERROR "\t临时文件未创建成功，请检查磁盘读写是否正常。"
    fi
    # 初始化计数器
    declare -A nat_counts
    # 读取临时文件并统计每个值的出现次数
    while read -r value; do
        # 去掉可能的逗号和空格
        value=$(echo "$value" | tr -d ',' | xargs)
        if [[ -n "$value" && "$value" =~ ^[0-9]+$ ]]; then  # 确保是数字
            ((nat_counts[$value]++))
        fi
    done < "$temp_file"
    # 输出统计结果
    for i in {1..6}; do
        if [[ ${nat_counts[$i]} -gt 0 ]]; then
            LOG_INFO "\tNAT\033[35m $i \033[0m类型数量: ${nat_counts[$i]}"
        fi
    done
    # 清理临时文件
    rm -f "$temp_file" 
}

# 查看反连状态
function p2pStatus() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始获取反连状态"
    step_flag=$(( ${step_flag} + 1 ))

    p2pStatus='/tmp/p2pStatus.txt'
    cat /tmp/net_link_prober.json | json_reformat | grep p2pStatus > $p2pStatus
    p2pSuccess=$(awk '{print $2}' $p2pStatus | egrep '^1,' | wc -l)
    p2pFailure=$(awk '{print $2}' $p2pStatus | egrep '^-1,' | wc -l)
    LOG_INFO "\t反连成功数量：$p2pSuccess"
    LOG_ERROR "\t反连失败数量：$p2pFailure"
    rm -f $p2pStatus
}


# 查看拨号异常线路
function pppStatus() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始检查拨号异常线路"
    step_flag=$(( ${step_flag} + 1 ))

    jq -r '.multidial[] | select(.errmsg != "ok") | "\(.tag)： \(.errmsg)"' /tmp/multidialstatus.json > /tmp/pppStatus.txt

    if [[ $(cat /tmp/pppStatus.txt | wc -l ) == 0 ]]; then
        LOG_INFO "\t所有线路拨号正常。"
    else
        LOG_ERROR "\t异常线路："
        while read -r errmsg; do
            # 提取线路编号和错误信息
            tag=$(echo "$errmsg" | awk -F'：' '{print $1}')
            errmsg=$(echo "$errmsg" | awk -F'：' '{print $2}')
            # 格式化输出并传递给 LOG_ERROR
            formatted_msg=$(printf "%-7s： %s" "$tag" "$errmsg")
            LOG_ERROR "\t$formatted_msg"
        done < /tmp/pppStatus.txt
    fi

    rm -f /tmp/pppStatus.txt
}

# 检查 dmesg 日志
function Error_dmesg() {
    LOG_WARN "[${step_flag}/${step_total}]\t开始检查 dmesg 日志"
    step_flag=$(( ${step_flag} + 1 ))

    if dmesg -T | grep "I/O error" | grep -q "sd"; then
        error_IO=$(dmesg -T | grep "I/O error" | tail -1)
        # LOG_ERROR "\t发现磁盘 I/O 异常："
        LOG_ERROR "\t$error_IO"
    else
        # echo -e "\033[32m未发现磁盘 I/O 错误。\033[0m"
        true
    fi

    if dmesg -T | grep -q "SYN"; then
        error_SYN=$(dmesg -T | grep "SYN" | tail -1)
        # LOG_ERROR "\t可能出现 SYN洪泛："
        LOG_ERROR "\t$error_SYN"
    else
        # echo -e "\033[32m未发现 SYN 洪泛。\033[0m"
        true
    fi

    if dmesg -T | grep -q "too many orphaned sockets"; then
        error_sockets=$(dmesg -T | grep "too many orphaned sockets" | tail -1)
        # LOG_ERROR "\t系统中存在过多的孤儿套接字："
        LOG_ERROR "\t$error_sockets"
    else
        # echo -e "\033[32m未发现过多的孤儿套接字。\033[0m"
        true
    fi

    if dmesg -T | grep -q "neighbour"; then
        error_neighbour=$(dmesg -T | grep "neighbour" | tail -1)
        # LOG_ERROR "\t路由表溢出："
        LOG_ERROR "\t$error_neighbour"
    else
        # echo -e "\033[32m未发现路由表溢出。\033[0m"
        true
    fi

    if dmesg -T | grep -q "HTB: quantum"; then
        quantum=$(dmesg -T | grep "HTB: quantum" | tail -1)
        # LOG_ERROR "\tquantum 值过大，可能会导致某些流量类别占用过多的带宽，影响其他流量的公平性："
        LOG_ERROR "\t$quantum"
    else
        true
    fi

    if dmesg -T | grep -q "oom-kill"; then
        oom=$(dmesg -T | grep "oom-kill" | tail -1)
        # LOG_ERROR "\toom-kill, 内存不足："
        LOG_ERROR "\t$oom"
    else
        true
    fi

    if dmesg -T | grep -q "bad checksum"; then
        oom=$(dmesg -T | grep "bad checksum" | tail -1)
        # LOG_ERROR "\t UDP: bad checksum. UDP 校验错误："
        LOG_ERROR "\t$oom"
    else
        true
    fi
}

################################################################################
# 执行检查
################################################################################

# echo -e "\033[33m\n\n开始检查 Guluserver 业务状态...\033[0m"
yum_repos
Basic_Information
disk_IOPS
p2pStatus
nat_sum
Business_Cache
check_pod
Error_dmesg
pppStatus
# Business_Press
Ping_check
Ping6_check