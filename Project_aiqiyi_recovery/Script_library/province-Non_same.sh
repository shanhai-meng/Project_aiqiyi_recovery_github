# Description: 跨省配置

# 项目配置
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function province-Non_same{
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	cp /etc/xyapp/recruitConfig.json /etc/xyapp/recruitConfig.json.bak-$(date +%F)
	sed -i 's/"update_dcache_config":[[:space:]]*false/"update_dcache_config": true/g' /etc/xyapp/recruitConfig.json
	chattr -i /etc/xyapp/recruitConfig.json
	sed -i 's/<servicerange>3<\/servicerange>/<servicerange>0<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
	sed -i 's/<servicerange>3<\/servicerange>/<servicerange>0<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml
	
	restart_ipes
	
	echo "查看文件锁"
	lsattr /etc/xyapp/recruitConfig.json
	echo "查看false情况"
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	echo "查看同省情况"
	grep servicerange /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
}

province-Non_same