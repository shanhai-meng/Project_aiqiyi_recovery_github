# Description: 更改端口号

# 项目配置
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function prot-change{
	# 获取当前端口号
	port_old=$(grep '<host' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml | awk -F'port="' '{print $2}' | awk -F'"' '{print $1}');
	# 生成一个新的端口
	random=$(shuf -i 9500-15000 -n 1)
	port_new=$random
	sed -i "s/port=\"$port_old\"/port=\"$port_new\"/" /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
	sed -i "s/port=\"$port_old\"/port=\"$port_new\"/" /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml
	echo "旧的端口值为 $port_old,已将端口号更新为 $port_new."   

	restart_ipes                                                                                                                                                                                                                                        
}

prot-change