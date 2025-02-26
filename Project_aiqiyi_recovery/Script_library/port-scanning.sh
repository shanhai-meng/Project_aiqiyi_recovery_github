# Description: 端口探测
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

function port-scanning{ 
    echo 
    echo -n "已识别到的v4线路数：" 
    curl -s --show-error http://127.0.0.1:8400/info?need=exportstatus | awk -F'<hostnum>' '{print $2}' | awk -F'</hostnum>' '{print $1}' 
    echo 
    echo -n  "已识别到的v6线路数：" 
    curl -s --show-error http://127.0.0.1:8400/info?need=exportstatus | awk -F'<ipv6num>' '{print $2}' | awk -F'</ipv6num>' '{print $1}' 
    echo ;echo "当前ip信息（若是移动则不通）：" 
    curl myip.ipip.net 
    echo 
    echo "反连探测状态"
    nc -zv $(curl -s --show-error http://127.0.0.1:8400/info?need=exportstatus | awk -F'<host>' '{print $2}' | awk -F'</host>' '{print $1}' \
    | awk -F: '{print $1}') $(curl -s --show-error http://127.0.0.1:8400/info?need=exportstatus | awk -F'<host>' '{print $2}' | awk -F'</host>' '{print $1}' | awk -F: '{print $2}') 
    echo
}

port-scanning