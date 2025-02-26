# Description: 同省配置

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

function province-same{
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	cp /etc/xyapp/recruitConfig.json /etc/xyapp/recruitConfig.json.bak-$(date +%F)
	sed -i 's/"update_dcache_config":[[:space:]]*true/"update_dcache_config": false/g' /etc/xyapp/recruitConfig.json
	chattr +i /etc/xyapp/recruitConfig.json;sed -i 's/<servicerange>0<\/servicerange>/<servicerange>3<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
	sed -i 's/<servicerange>0<\/servicerange>/<servicerange>3<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml

	restart_ipes

	echo "查看文件锁"
	lsattr /etc/xyapp/recruitConfig.json
	echo "查看false情况"
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	echo "查看同省情况"
	grep servicerange /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
}

province-same