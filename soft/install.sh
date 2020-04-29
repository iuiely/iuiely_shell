#!/bin/bash

##-----------------------------------------------------------##
##  显示所有可以安装的软件
function software_help(){
    printf "\t\t 当前可安装的软件列表如下：\n"
    for software in $(ls ${DIR}/modules);do
        printf "\t\t %s \t \n" ${software}
    done
    printf "\n"
}
##  显示所有可安装软件的版本
function version_help(){
    local software=$1
    local version
    printf "\t\t %s软件可安装的版本列表如下：\n" ${software}
    for version in $(ls ${DIR}/modules/${software});do
        printf "\t\t %s \t \n" ${version}
    done
}
##  脚本的使用帮助
function help(){
    printf "\t\t 脚本的使用帮助:\n"
    printf "\t\t ./%s 可安装的软件名 软件版本 \n" $0
    printf "\t\t 例如：./%s nginx 1.16.1 \n" $0
    printf "\n"
}
##-----------------------------------------------------------##
DIR=$(cd $(dirname $0);pwd)
##  安装软件的日志文件
install_log=${DIR}/software-install.log
param_number=$#
##  传入的第1个参数是将要安装的软件，必须是已定义的并且存在的软件
soft=$1
##  传入的第2个参数是将要安装软件的版本，必须是已定义的版本
version=$2

case $param_number in
    1)
        version_help ${soft}
    ;;
    #  在输入了2个脚本参数的情况下，进行的逻辑操作
    2)
        #  软件版本定义文件
        software_version="${DIR}/modules/${soft}/${version}"
        #  安装软件的执行逻辑
        if [ -f ${software_version} ];then 
            #  读取将要安装的软件定义
            source ${software_version}
            #  根据定义的安装方式安装软件，安装方式在定义文件中设置
            case $method in
                yum)
                    if [ -f ${des_server_list} ];then
                        for server in $(cat ${des_server_list});do
                            #  检测将要安装软件的服务器的可用性
                            ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                            if [ $? -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                                install_result=$(${method}_${soft}) >/dev/null 2>&1
                                if [ ${install_result} -eq 0 ];then
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                                else
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                                fi
                            fi
                        done
                    fi
                  ;;
                compile)
                    if [ -f ${code_resource} ]&& [ -f ${des_server_list} ];then
                        for server in $(cat ${des_server_list});do
                            #  检测将要安装软件的服务器的可用性
                            ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                            if [ $? -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                                install_result=$(${method}_${soft}) >/dev/null 2>&1
                                if [ ${install_result} -eq 0 ];then
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                                else
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                                fi
                            fi
                        done
                    fi
                  ;;
                *)
                    printf  "软件安装方式%s未定义，请定义这个安装方式.\n" ${method}
                  ;;
            esac
        else
            printf "准备安装软件%s的版本%s的定义文件不存在.\n" ${soft} ${version}
        fi
    ;;
    #  在输入了3个脚本参数的情况下，进行的逻辑操作
    3)
        #  软件版本定义文件
        software_version="${DIR}/modules/${soft}/${version}"
        #  安装软件的执行逻辑
        if [ -f ${software_version} ];then 
            #  读取将要安装的软件定义
            source ${software_version}
            #  将要安装软件的远程服务器
            des_server_list=$3
            #  根据定义的安装方式安装软件，安装方式在定义文件中设置
            case $method in
                yum)
                    if [ -f ${des_server_list} ];then
                        for server in $(cat ${des_server_list});do
                            #  检测将要安装软件的服务器的可用性
                            ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                            if [ $? -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                                install_result=$(${method}_${soft}) >/dev/null 2>&1
                                if [ ${install_result} -eq 0 ];then
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                                else
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                                fi
                            fi
                        done
                    elif [ ! -f ${des_server_list} ];then
                        server=${des_server_list}
                        #  检测将要安装软件的服务器的可用性
                        ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                        if [ $? -eq 0 ];then
                            printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                            install_result=$(${method}_${soft}) >/dev/null 2>&1
                            if [ ${install_result} -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                            else
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                            fi
                        fi
                    else
                        printf "%s的格式错误，必须是可访问的服务器列表文件或者是可访问的服务器.\n" ${des_server_list}
                    fi
                  ;;
                compile)
                    if [ -f ${des_server_list} ];then
                        for server in $(cat ${des_server_list});do
                            #  检测将要安装软件的服务器的可用性
                            ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                            if [ $? -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                                install_result=$(${method}_${soft}) >/dev/null 2>&1
                                if [ ${install_result} -eq 0 ];then
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                                else
                                    printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                                fi
                            fi
                        done
                    elif [ ! -f ${des_server_list} ];then
                        server=${des_server_list}
                        #  检测将要安装软件的服务器的可用性
                        ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
                        if [ $? -eq 0 ];then
                            printf "$(date "+%F %H:%M:%S") 在%s服务器上开始使用%s方法安装软件%s.\n" ${server} ${method} ${soft} >> ${install_log}
                            install_result=$(${method}_${soft}) >/dev/null 2>&1
                            if [ ${install_result} -eq 0 ];then
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s成功.\n" ${server} ${method} ${soft} >> ${install_log}
                            else
                                printf "$(date "+%F %H:%M:%S") 在%s服务器上使用%s方法安装软件%s失败.\n" ${server} ${method} ${soft} >> ${install_log}
                            fi
                        fi
                    else
                        printf "%s的格式错误，必须是可访问的服务器列表文件或者是可访问的服务器.\n" ${des_server_list}
                    fi
                  ;;
                *)
                    printf  "软件安装方式%s未定义，请定义这个安装方式.\n" ${method}
                  ;;          
            esac
        else
            printf "准备安装软件%s的版本%s的定义文件不存在.\n" ${soft} ${version}
        fi
    ;;
    *)
       help
       software_help
    ;;
esac
