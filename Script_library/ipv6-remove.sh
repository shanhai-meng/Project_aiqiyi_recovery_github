# Description: 移除onlyipv6配置

function remove-onlyipv6{
	if grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null ;then
		echo 
		echo "当前配置为onlyipv6" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml && echo "修改主配置文件成功" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml && echo "修改data配置文件成功" 
		
		if docker ps | grep k8s > /dev/null ;then
			echo "当前为k8s，尝试重启容器"
			docker restart `docker ps -qa` 
		else
			echo "当前非k8s,尝试重启ipes"
			/opt/soft/ipes/bin/ipes stop && /opt/soft/ipes/bin/ipes start && echo "重启ipes成功" || echo "重启ipes失败"
		fi
		grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && echo "onlyipv6配置移除失败，等待自动恢复" 
	else    
		echo "当前非onlyipv6" 
	fi
	grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && echo "onlyipv6配置移除失败，等待自动恢复" 
	echo
}
