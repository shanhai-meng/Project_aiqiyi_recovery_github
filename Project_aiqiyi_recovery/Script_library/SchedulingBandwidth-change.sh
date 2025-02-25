# Description: 更改调度带宽

# 项目配置
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function SchedulingBandwidth-change() {
    echo "标准调度带宽大小(单位M/B)：" $(jq -r '(.per_line_bandwidth * (.line_number / 8))' /etc/xyapp/export_bandwidth_corrected.json)
    echo "配置调度带宽大小(单位M/B)：" $(grep bandwidth /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml  | awk -F'<bandwidth>|</bandwidth>' '{print $2}') 
    read -p "是否修改调度带宽？(y/n)" yn 
    if [ $yn = "y" ];then 
        read -p "请输入新的调度带宽(单位M/B)：" new_bandwidth
        sed -i "s/<bandwidth>.*<\/bandwidth>/<bandwidth>$new_bandwidth<\/bandwidth>/" /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml 
        sed -i "s/<bandwidth>.*<\/bandwidth>/<bandwidth>$new_bandwidth<\/bandwidth>/" /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml 
        echo "调度带宽已更新为 $new_bandwidth." 
        
        restart_ipes
    else 
        echo""
fi
}