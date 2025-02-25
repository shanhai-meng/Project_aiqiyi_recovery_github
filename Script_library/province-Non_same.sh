# Description: 跨省配置

function Non_same_province{
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	cp /etc/xyapp/recruitConfig.json /etc/xyapp/recruitConfig.json.bak-$(date +%F)
	sed -i 's/"update_dcache_config":[[:space:]]*false/"update_dcache_config": true/g' /etc/xyapp/recruitConfig.json
	chattr -i /etc/xyapp/recruitConfig.json
	sed -i 's/<servicerange>3<\/servicerange>/<servicerange>0<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
	sed -i 's/<servicerange>3<\/servicerange>/<servicerange>0<\/servicerange>/g' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml
	if docker ps | grep k8s > /dev/null ;then
		echo "当前为k8s，尝试重启容器"
		docker restart `docker ps -qa` 
	else
		echo "当前非k8s,尝试重启ipes"
		/opt/soft/ipes/bin/ipes stop && /opt/soft/ipes/bin/ipes start && echo "重启ipes成功" || echo "重启ipes失败"
	fi   
	echo "查看文件锁"
	lsattr /etc/xyapp/recruitConfig.json
	echo "查看false情况"
	cat /etc/xyapp/recruitConfig.json |python -m json.tool |grep update_dcache_config
	echo "查看同省情况"
	grep servicerange /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
}