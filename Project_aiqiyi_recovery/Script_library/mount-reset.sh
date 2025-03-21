# Description: 重置挂载点

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

function mount-reset() {
	/opt/soft/ipes/bin/ipes stop
	umount -i /data* && sleep 5
	umount /data*
	cd /etc/yum.repos.d/ && mkdir backup && mv CentOS-* backup/ && wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo >> /dev/null && cd ~ ; yum -y install jq >> /dev/null
	map_info=$(jq '.storage_info' /etc/xyapp/dockerBinTask/dockerBinTaskMountInfo.json)
	echo "$map_info" | jq -c 'to_entries[]' | while read line;
	do  
		device=$(echo "$line" | jq -r '.key')
		mount_point=$(echo "$line" | jq -r '.value')
   # 尝试挂载
    mount "$device" "$mount_point"
    if [ $? -eq 0 ]; then
        echo "Mounted $device to $mount_point"
    else
        # 如果挂载失败，提示错误信息
        echo "Failed to mount $device to $mount_point. Attempting to format the disk..."

        # 格式化磁盘
        mkfs.xfs "$device"
        if [ $? -eq 0 ]; then
            echo "Formatted $device with XFS filesystem."

            # 再次尝试挂载
            mount "$device" "$mount_point"
            if [ $? -eq 0 ]; then
                echo "Mounted $device to $mount_point after formatting."
            else
                echo "Failed to mount $device to $mount_point even after formatting. Please check the device and mount point."
            fi
        else
            echo "Failed to format $device with XFS filesystem. Please check the device."
        fi
    fi
	done  
}

mount-reset



