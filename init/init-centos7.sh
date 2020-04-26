#!/bin/bash
DIR=$( cd "$( dirname "$0"  )" && pwd  )
source ${DIR}/config


##################################################################################
## 包含全部初始化项目
source ${DIR}/define/remote_server_check
source ${DIR}/define/remote_server_common_init
source ${DIR}/define/remote_server_diff_init
##################################################################################
## 初始化操作  X是某个机房的代号
function x_init(){
    check_expect
    delete_known_hosts
    check_ip
    check_passwd
    check_new_host
    close_selinux
    copy_key
    close_services
    close_ipv6
    add_user
    change_mem_page
    change_kernel
    change_limit
    change_sshd
    change_selinux
    change_systemd
    set_dns_resolv
    set_root_password
    set_yum_repo
    set_hosts
    install_packet
    install_zabbix_agent
    config_zabbix_agent
    reboot_server
}
##################################################################################
if [ $# -ne 3 ];then
	echo '需要3个参数，参数1是函数名，参数2是服务器IP地址，参数3是密码 '
	exit 3
fi
##    $1=Function $2=IP $3=password  $4=log file
ip="$2"
password="$3"
file="/tmp/initialization.log"
$1 $2 $3
