# Description: 重用函数

# 环境准备
function Env_preparation() {
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



