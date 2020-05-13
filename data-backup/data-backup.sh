#!/bin/bash
export PATH=PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

source $(cd $(dirname $0);pwd)/config
##-------------------------------------------------------##
function help(){
    local project
    printf "\t %s 脚本的使用方法如下: \n" $0
    printf "\t %s 备份的项目名称 \n" $0
    printf "\t\t 项目名称必须在config配置文件的back_define变量指定的目录中存在.例如:在这个变量的目录中定义了plat-nginx-logs备份项目\n"
    printf "\t\t 示例: %s plat-nginx-logs \n" $0
    printf "\n \t 当前已经定义的备份项目列表如下:\n"
    for project in $(ls ${DIR}/${back_define}/);do
        printf "\t\t %s \n\n" ${project}
    done
}
function check_remote_server(){
    local server=$1
    ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
    echo $?
}
##-------------------------------------------------------##
DIR=$(cd $(dirname $0);pwd)
param_number=$#
back_project=$1
##-------------------------------------------------------##
case $param_number in
    1)
        project_define_file=${DIR}/${back_define}/${back_project}
        if [ ! -f ${project_define_file} ];then
            printf "\t 将要操作的备份定义文件不存在，请重新输入\n"
            exit 101
        fi
        DATE=$(date +%F-%H)
        source ${project_define_file}
        for server in ${SERVER_LIST[@]};do
            server_check_result=$(check_remote_server ${server})
            if [ ${server_check_result} -eq 0 ] ;then
                if [ ! -d ${backup_project}/${server} ];then
                    mkdir -p  ${backup_project}/${server}
                fi
                back_fun ${server}
            else
                printf "\t 连接设备 \t %s \t Failed \n \n" ${server}
                continue
            fi
        done
      ;;
    *)
        help
      ;;
esac
