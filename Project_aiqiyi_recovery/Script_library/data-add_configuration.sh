# Description: 添加数据盘配置

# 变量定义（用户配置项）
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $project_conf
source $Reuse_Function

function data_add_configuration() {
	
	Env_preparation # 环境准备

	echo
	echo "参考值cap大小（这些是已经写入配置文件中的）：" 
	jq '.storage.diskinfo' /opt/soft/ipes/var/db/ipes/css-conf/cssconfig.json | jq -c 'to_entries[]'
	echo 
	echo "挂载点信息：" 
	lsblk | grep _lv | grep -v _vg_lv
	echo 
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

	restart_ipes
}
           
data_add_configuration