#!/bin/bash

##----------------------------------------##
##  载入环境配置变量定义
source $(cd $(dirname $0);pwd)/config
##  载入函数
for fun_file in $(find $(cd $(dirname $0);pwd)/${fun_dir} -type f);do
    source ${fun_file}
done

##----------------------------------------##
DIR=$(cd $(dirname $0);pwd)
param_number=$#
work=$1
server=$2

##----------------------------------------##

case $work in
    cmd)
        cmd=$3
        case $param_number in
            3)
                des_server_file=${DIR}/${store_server_dir}/${server}
                if [ ! -f ${des_server_file} ];then
                    printf "\t 将要操作的目录服务器列表文件不存在，请重新输入\n"
                    exit 101
                fi
                open_proc ${des_server_file} ${work} "${cmd[@]}"
              ;;
            *)
                cmd_help
              ;;
        esac    
      ;;
    cp)
        case $param_number in
            4)
                source=$3
                dest=$4
                des_server_file=${DIR}/${store_server_dir}/${server}
                if [ ! -f ${des_server_file} ];then
                    printf "\t 将要操作的目录服务器列表文件不存在，请重新输入\n"
                    exit 101
                fi
                open_proc ${des_server_file} ${work} ${source} ${dest}
              ;;
            *)
                cp_help
              ;;
        esac    
      ;;
    *)
        help
      ;;
esac 
