#!/bin/bash
source $(cd $(dirname $0);pwd)/config
#---------------------------------------------------------#
function help(){
    echo ""
    printf "\t\t %s 配置应用软件脚本的使用方法\n" $0
    printf "\t\t new 参数，编辑软件项目的配置文件，这个项目配置文件必须在远程服务器中不存在\n"
    printf "\t\t edit 参数，编辑软件项目的配置文件，并且要编辑的配置文件必须要存在\n"
    printf "\t\t backup 参数，备份软件项目的配置文件，这个项目配置文件在远程服务器上必须要存在\n"
    printf "\t\t update 参数，更新软件项目的配置文件，本地的配置文件必须要存在\n"
    echo ""
}
function edit_help(){
    echo ""
    printf "\t\t 使用编辑参数的时候，只能输入要编辑配置的软件名和目标项目\n"
    echo ""
    printf "\t\t 当前可编辑配置的应用软件和项目列表：\n"
    local software project
    for software in $(ls ${DIR}/${define});do
        printf "\t\t     %s    可配置的项目列表: \n" $software
        for project in $(ls ${DIR}/${define}/${software});do
            printf "\t\t\t %s \n" ${project}
        done
    done
    echo ""
}
function edit_project_help(){
    local software=$1
    local project
    printf "\t\t %s    可配置的项目列表: \n" $software
    for project in $(ls ${DIR}/${define}/${software});do
        printf "\t\t     %s \n" ${project}
    done
}
function backup_help(){
    echo ""
    printf "\t\t 使用备份参数的时候，可以输入要备份配置的软件名、目标项目、目标服务器地址\n"
    echo ""
    printf "\t\t 当前可备份配置的应用软件和项目列表：\n"
    local software project
    for software in $(ls ${DIR}/${define});do
        printf "\t\t     %s    可备份配置的项目列表: \n" $software
        for project in $(ls ${DIR}/${define}/${software});do
            printf "\t\t\t %s \n" ${project}
        done
    done
    echo ""
}
function backup_project_help(){
    local software=$1
    local project
    printf "\t\t %s    可备份配置的项目列表: \n" $software
    for project in $(ls ${DIR}/${define}/${software});do
        printf "\t\t     %s \n" ${project}
    done
}
function new_work_help(){
    echo ""
    printf "\t new 参数新建软件配置或定义，需要输入选定的工作、软件名、项目名\n"
    echo ""
    printf "\t 当前可新增配置或定义的软件列表：\n"
    local software
    for software in $(ls ${DIR}/${define});do
        printf "\t %s \n" $software
    done
}
function new_soft_config_help(){
    local software=$1
    local config_define
    printf "\t 当前软件%s已存在的项目定义列表如下：\n" ${software}
    for config_define in $(ls ${DIR}/${confs}/${software});do
        printf "\t %s \n" $config_define
    done
}
function new_soft_help(){
    echo ""
    printf "\t\t new 参数新建软件配置或定义，需要输入选定的工作、软件名、项目名\n"
    printf "\t\t 可选工作参数限定是 project 、config 之一 \n"
    printf "\t\t 当前可新增配置或定义的软件列表：\n"
    local software
    for software in $(ls ${DIR}/${define});do
        printf "\t\t %s \n" $software
    done
    echo ""
}
update_project_conf_help(){
    local env=$1
    local software=$2
    local project
    printf "\t\t 参数 upate ,环境 %s ,更新配置的软件 %s 、还需输入项目名，可选择输入目标服务器地址或列表文件\n" ${env} ${software}
    printf "\t\t %s    可更新配置的项目列表: \n" $software
    for project in $(ls ${DIR}/${define}/${software});do
        printf "\t\t     %s \n" ${project}
    done
}
update_software_help(){
    echo ""
    printf "\t\t 使用更新配置参数的时候，需要输入要更新配置的环境、软件名、项目名，可选择输入目标服务器地址或列表文件\n"
    printf "\t\t 使用更新配置参数的时候，需要输入将更新配置的环境,限定环境必须是 test、product \n"
    printf "\t\t 当前可更新配置的软件和项目列表：\n"
    local software project
    for software in $(ls ${DIR}/${define});do
        printf "\t\t     %s    可配置的项目列表: \n" $software
        for project in $(ls ${DIR}/${define}/${software});do
            printf "\t\t\t %s \n" ${project}
        done
    done
    echo ""
}
update_soft_env_help(){
    local env=$1
    echo ""
    printf "\t\t 参数 upate ,环境 %s ,还需输入想要更新配置的软件名、项目名，可选择输入目标服务器地址或列表文件\n" ${env}
    echo ""
    printf "\t\t 当前可更新配置的软件和项目列表：\n"
    local software project
    for software in $(ls ${DIR}/${define});do
        printf "\t\t     %s    可配置的项目列表: \n" $software
        for project in $(ls ${DIR}/${define}/${software});do
            printf "\t\t\t %s \n" ${project}
        done
    done
    echo ""
}
function edit_config(){
    local edit
    edit=$(whereis vim|awk '{print $2}')
    if [ ! -z ${edit} ];then
        ${edit} ${local_confs_file}
    else
        printf "  vim 命令不存在，请先安装.\n"
        exit 9
    fi
}
function new_config_file(){
    local edit
    edit=$(whereis vim|awk '{print $2}')
    if [ -z ${edit} ];then
        printf "  vim 命令不存在，请先安装.\n"
        exit9
    fi
    if [ ! -d ${local_confs_dir} ];then
        mkdir -p ${local_confs_dir}
    fi
    ${edit} ${local_confs_file}
}
function new_project_define(){
    local software=$1
    local project=$2
    if [ ! -d ${DIR}/${define}/${software} ];then
        mkdir -p ${DIR}/${define}/${software}   
    fi
    /bin/cp ${default_define_template} ${DIR}/${define}/${software}/${project}
}
function project_define(){
    local projectdefine=${DIR}/${define}/${soft}/${project}
    if [ ! -f ${projectdefine} ];then
        printf " %s 软件的 %s 项目定义文件不存在.\n" ${soft} ${project}
        exit 10
    fi
    source ${projectdefine}
}
function backup_config(){
    if ssh root@${server} " test -f ${dest_confs_file} ";then
        for backfile in $(ls ${backup_dir}|grep last);do
            mv ${backup_dir}/${backfile} ${backup_dir}/${backfile%%_*}
        done
        scp -P ${port} root@${server}:${dest_confs_file} ${backup_file}  >/dev/null 2>&1
    else
        printf " %s 软件的项目 %s 要备份的配置文件在生产环境中不存在.\n" ${soft} ${project}
        exit 99
    fi
}
function check_remote_server(){
    local server=$1
    ping -c 2 -w 1 -i 0.01 ${server} > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "远程目标服务器无法连接"
        exit 99
    fi
}
function create_backup_dir(){
    local backup_dir=$1
    if [ ! -d ${backup_dir} ]; then
        mkdir -p ${backup_dir}
    fi
}
#---------------------------------------------------------#
DIR=$(cd $(dirname $0);pwd)

param_number=$#

action=$1

soft=$2

project=$3

#---------------------------------------------------------#
case $action in
    new)
        work=$2
        soft=$3
        project=$4
        case $work in
            project)
                case $param_number in
                    3)
                        new_soft_config_help ${soft}
                      ;;
                    4)
                        new_project_define ${soft} ${project}
                      ;;
                    *)
                        new_work_help ${soft}
                      ;;
                esac
              ;;
            config)
                case $param_number in
                    3)
                        new_soft_config_help ${soft}
                      ;;
                    4)
                        project_define
                        new_config_file
                      ;;
                    *)
                        new_work_help ${soft}
                      ;;
                esac
              ;;
            *)
                new_soft_help     
              ;;
        esac
      ;;
    edit)
        case $param_number in
            2)
                edit_project_help ${soft}
              ;;
            3)
                project_define
                if [ ! -z ${local_confs_file} ] && [ -f ${local_confs_file} ] && [ -f ${project_dest_server_list} ];then
                    last_backup_file=$(ls ${backup_dir}|grep last)
                    /bin/cp ${backup_dir}/${last_backup_file} ${local_confs_file}
                    edit_config ${local_confs_file}
                else
                    printf " %s 软件的项目 %s 要编辑的配置文件不存在,或者远程目标服务器列表文件不存在.\n" ${soft} ${project}
                    printf " 需要创建项目 %s 的配置文件,这个配置文件的路径是 %s \n" ${project} ${local_confs_file}
                    printf " 需要创建项目 %s 的服务器列表文件，这个列表文件的路径是 %s \n" ${project} ${project_dest_server_list}
                    exit 11
                fi
              ;;
            *)
                edit_help
              ;;
        esac
      ;;
    backup)
        case $param_number in
            2)
                backup_project_help ${soft}
              ;;
            3)
                project_define
                if [ ! -f ${project_dest_server_list} ];then
                    printf " 要备份软件%s 的项目 %s 的远程目标服务器列表文件不存在\n" ${soft} ${project}  
                    exit 100
                fi
                server=$(awk '$2=="product"{print $1}' ${project_dest_server_list}|tail -n1)
                check_remote_server ${server}
                create_backup_dir ${backup_dir}
                backup_config
              ;;
            4)
                project_define
                project_dest_server_list=$4
                if [ -f ${project_dest_server_list} ];then
                    server=$(awk '$2=="product"{print $1}' ${project_dest_server_list}|tail -n1)
                    check_remote_server ${server}
                    create_backup_dir ${backup_dir}
                    backup_config
                elif [ ! -f ${project_dest_server_list} ];then
                    server=${project_dest_server_list}
                    check_remote_server ${server}
                    create_backup_dir ${backup_dir}
                    backup_config
                fi
              ;;
            *)
                backup_help
              ;;
        esac    
      ;;
    update)
        environment=$2
        soft=$3
        project=$4
        case ${environment} in
            test)
                case $param_number in
                    3)
                        update_project_conf_help ${environment} ${soft}
                      ;;
                    4)
                        project_define 
                        if [ ! -f ${project_dest_server_list} ];then
                            printf " 更新软件%s 的项目 %s 的远程目标服务器列表文件不存在\n" ${soft} ${project}
                            exit 100
                        fi
                        for server in $(awk -v env=$environment '$2==env{print $1}' ${project_dest_server_list});do
                            check_remote_server ${server}
                            scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                            dest_software_reload ${server}
                        done
                      ;;
                    5)
                        project_define 
                        project_dest_server_list=$5
                        if [ -f ${project_dest_server_list} ];then
                            for server in $(awk -v env=$environment '$2==env{print $1}' ${project_dest_server_list});do
                                check_remote_server ${server}
                                scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                                dest_software_reload ${server}
                            done
                        elif [ ! -f ${project_dest_server_list} ];then
                            server=${project_dest_server_list}
                            check_remote_server ${server}
                            scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                            dest_software_reload ${server}
                        fi
                      ;;
                    *)
                        update_soft_env_help ${environment}
                      ;;
                esac
              ;;
            product)
                case $param_number in
                    3)
                        update_project_conf_help ${environment} ${soft}
                      ;;
                    4)
                        project_define 
                        if [ ! -f ${project_dest_server_list} ];then
                            printf " 更新软件%s 的项目 %s 的远程目标服务器列表文件不存在\n" ${soft} ${project}
                            exit 100
                        fi
                        for server in $(awk -v env=$environment '$2==env{print $1}' ${project_dest_server_list});do
                            check_remote_server ${server}
                            create_backup_dir ${backup_dir}
                            backup_config
                            scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                            dest_software_reload ${server}
                        done
                      ;;
                    5)
                        project_define
                        project_dest_server_list=$5
                        if [ -f ${project_dest_server_list} ];then
                            for server in $(awk -v env=$environment '$2==env{print $1}' ${project_dest_server_list});do
                                check_remote_server ${server}
                                create_backup_dir ${backup_dir}
                                backup_config
                                scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                                dest_software_reload ${server}
                            done
                        elif [ ! -f ${project_dest_server_list} ];then
                            server=${project_dest_server_list}
                            create_backup_dir ${backup_dir}
                            backup_config
                            check_remote_server ${server}
                            scp -P ${port} ${local_confs_file} root@${server}:${dest_confs_file}  >/dev/null 2>&1
                            dest_software_reload ${server}
                        fi
                      ;;
                    *)
                        update_soft_env_help ${environment}
                      ;;
                esac
              ;;
            *)
                update_software_help
              ;;
        esac
      ;;
    *)
        help 
      ;;
esac
