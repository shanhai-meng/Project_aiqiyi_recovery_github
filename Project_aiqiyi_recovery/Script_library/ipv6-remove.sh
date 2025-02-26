# Description: 移除onlyipv6配置

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

# 颜色定义
function Color_Red() {
  echo -e "\033[31m${1}\033[0m"
}
function Color_Green() {
  echo -e "\033[32m${1}\033[0m"
}
function Color_Yellow() {
  echo -e "\033[33m${1}\033[0m"
}

function ipv6-remove() {
	if grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null ;then
		Color_Yellow "当前配置为onlyipv6" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml && Color_Green "修改主配置文件成功" 
		sed -i 's/<onlyipv6>1<\/onlyipv6>/<onlyipv6>0<\/onlyipv6>/' /opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml && Color_Green "修改data配置文件成功" 
		
		restart_ipes
		
		grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && Color_Red "onlyipv6配置移除失败，等待自动恢复" 
	else    
		Color_Green "当前非onlyipv6" 
	fi
	grep '<onlyipv6>1</onlyipv6>' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml > /dev/null && Color_Red "onlyipv6配置移除失败，等待自动恢复" 
	echo
}

ipv6-remove