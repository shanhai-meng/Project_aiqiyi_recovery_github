# Description: 清除缓存

# 变量定义（用户配置项）
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function cache-clean{

	Env_preparation	# 环境准备
	
	/opt/soft/ipes/bin/ipes stop
	umount -i /data* 
	sleep 5
	umount /data*
	echo 
	echo "逻辑卷信息："
	mklv=$(lvdisplay | grep Path | grep -v _vg_lv | awk '{print $3}')

	while read line;
	do 
		mkfs.xfs -f $line
	done <<< "$mklv"

	map_info=$(jq '.storage_info' /etc/xyapp/dockerBinTask/dockerBinTaskMountInfo.json)

	echo "$map_info" | jq -c 'to_entries[]' | while read line;
	do
		device=$(echo "$line" | jq -r '.key')
		mount_point=$(echo "$line" | jq -r '.value')
		mount "$device" "$mount_point"
		echo "Mounted $device to $mount_point"
	done
} 

cache-clean