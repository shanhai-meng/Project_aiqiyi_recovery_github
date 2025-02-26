# Description: 重置挂载点

# 项目配置
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function mount-reset{
	/opt/soft/ipes/bin/ipes stop
	umount -i /data* && sleep 5
	umount /data*
	cd /etc/yum.repos.d/ && mkdir backup && mv CentOS-* backup/ && wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo >> /dev/null && cd ~ ; yum -y install jq >> /dev/null
	map_info=$(jq '.storage_info' /etc/xyapp/dockerBinTask/dockerBinTaskMountInfo.json)
	echo "$map_info" | jq -c 'to_entries[]' | while read line;
	do  
		device=$(echo "$line" | jq -r '.key')
		mount_point=$(echo "$line" | jq -r '.value')
		mount "$device" "$mount_point"
		echo "Mounted $device to $mount_point"
	done  
}

mount-reset