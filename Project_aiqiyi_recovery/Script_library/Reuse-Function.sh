# Description: 重用函数


# 字体颜色定义
function Color_Green() {
  echo -e "\033[32m${1}\033[0m"
}

function Color_Yellow() {
  echo -e "\033[33m${1}\033[0m"
}

function Color_Red() {
  echo -e "\033[31m${1}\033[0m"
}


# 环境准备
function Env_preparation() {
    cd /etc/yum.repos.d/ 
	mkdir backup  >> /dev/null
	mv CentOS-* backup/ >> /dev/null
	wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo >> /dev/null 
	cd ~
    yum -y install jq >/dev/null 2&>1 || echo "jq 安装失败！"
}


# 重启ipes
function restart_ipes() {
 if docker ps | grep k8s > /dev/null ;then
  echo "当前为k8s，尝试重启容器"
  docker restart `docker ps -qa` 
 else
  echo "当前非k8s,尝试重启ipes"
  /opt/soft/ipes/bin/ipes stop && /opt/soft/ipes/bin/ipes start && echo "重启ipes成功" || echo "重启ipes失败"
 fi     
}



