# Description: 移除onlyipv6配置

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

function ipv6-remove{
	if grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null ;then
		echo 
		echo "当前配置为onlyipv6" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml && echo "修改主配置文件成功" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml && echo "修改data配置文件成功" 
		
		restart_ipes
		
		grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && echo "onlyipv6配置移除失败，等待自动恢复" 
	else    
		echo "当前非onlyipv6" 
	fi
	grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && echo "onlyipv6配置移除失败，等待自动恢复" 
	echo
}

ipv6-remove