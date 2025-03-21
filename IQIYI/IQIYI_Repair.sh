#!/bin/bash
################################################################################
# 内容概要：Guluserver故障检测脚本
# 作者信息：Mengrun<Mengrun@onething.net>
# 更新时间：2025-02-28 2:00
################################################################################

################################################################################
# 日志输出方法定义
################################################################################

function Color_Red() {
  echo -e "\033[31m\t${1}\033[0m"
}
function Color_Green() {
  echo -e "\033[32m\t${1}\033[0m"
}
function Color_Yellow() {
  echo -e "\033[33m\t${1}\033[0m"
}

function LOG_INFO() {
  echo -e "\033[32m\tINFO\t\t${1}\033[0m"
}

function LOG_WARN() {
  echo -e "\033[33m\tWARN\t\t${1}\033[0m"
}

function LOG_ERROR() {
  echo -e "\033[31m\tERROR\t\t${1}\033[0m"
}
################################################################################
# 常量定义
################################################################################

##脚本配置文件

################################################################################
# 修复模块
################################################################################
# 清理缓存
function cache-clean() {

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

function data_add_configuration() {
	
# 添加磁盘配置文件   

	echo -e "\n参考值cap大小（这些是已经写入配置文件中的）：\n" 
	jq '.storage.diskinfo' /opt/soft/ipes/var/db/ipes/css-conf/cssconfig.json | jq -c 'to_entries[]'
	echo -e "挂载点信息：\n" 
	lsblk | grep _lv | grep -v _vg_lv
	read -p "请输入要写入配置文件中的是data几？" data_num
	read -p "请输入要写入配置文件中data的大小？" size_lv  
	config_file="/opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml"
	config_file2="/opt/soft/ipes/var/db/ipes/dcache-data/conf/dcache.xml"
	if grep -q '<SSDConfig/>' "$config_file" ;then
		sed -i 's/<SSDConfig\/>/<SSDConfig>/' "$config_file" 
		sed -i '/<SSDConfig>/a\</SSDConfig>' "$config_file" 
		sed -i '/<SSDConfig>/a\<ssddir file_path="\/data'$data_num'\/vod">'$size_lv'</ssddir>' "$config_file" 
		sed -i 's/<SSDConfig\/>/<SSDConfig>/' "$config_file2" 
		sed -i '/<SSDConfig>/a\</SSDConfig>' "$config_file2" 
		sed -i '/<SSDConfig>/a\<ssddir file_path="\/data'$data_num'\/vod">'$size_lv'</ssddir>' "$config_file2"
	else 
		sed -i '/<SSDConfig>/a\<ssddir file_path="\/data'$data_num'\/vod">'$size_lv'</ssddir>' "$config_file"
		sed -i '/<SSDConfig>/a\<ssddir file_path="\/data'$data_num'\/vod">'$size_lv'</ssddir>' "$config_file2" 
	fi

	css_file=/opt/soft/ipes/var/db/ipes/css-conf/cssconfig.json
	css_data=/opt/soft/ipes/var/db/ipes/css-data/conf/cssconfig.json 
	jq '.storage.diskinfo += [{"diskpath": "/data'$data_num'/vod/", "cap": '$size_lv'}]' "$css_file" > "$css_file".bak && mv -f "$css_file".bak "$css_file"
	jq '.storage.diskinfo += [{"diskpath": "/data'$data_num'/vod/", "cap": '$size_lv'}]' "$css_data" > "$css_data".bak &&  mv -f "$css_data".bak "$css_data"
	jq '.storage.disknum += 1' "$css_file" > "$css_file".bak && mv -f "$css_file".bak "$css_file"
	jq '.storage.disknum += 1' "$css_data" >"$css_data".bak && mv -f "$css_data".bak "$css_data" 

}

# 删除onlyipv6
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

################################################################################
# 检查修复
################################################################################

