#!/bin/bash
#--------------------函数区-----------------------#
#检测新增用户名规则，用户名长度3到10位，必须由大小写字母、数字、下划线组成
function check_username(){
    local username=$1
    echo ${username}|grep "^[a-zA-Z0-9_]\{3,10\}$" > /dev/null
    echo $?
}
#检测新增的用户是否已存在
function check_user_exist(){
    local user=$1
    local ip=$2
    local port=$3
    ssh -p ${port} root@${ip} "awk -F':' -v user=${user} '\$1==user{print NR}' /etc/passwd" < /dev/null
}
#新增带家目录的用户，在新增用户的时候输入了密码，代表用户有login权限
function add_home(){
    local user=$1
    local password=$2
    local ip=$3
    local port=$4
    ssh -p ${port} root@${ip} useradd $user < /dev/null
    if [ $? -eq 0 ];then
        ssh -p ${port} root@${ip} "echo '"$user:$password"' | chpasswd" </dev/null
        printf "$(date "+%F %H:%M:%S") 在服务器 %s 中添加有密码可登录的用户 %s 成功，用户密码是 %s\n" ${ip} $user $password 
        echo -e " ${ip}\t $user\t\t $password\t\t $(date "+%F %H:%M:%S")\t\t 新增用户成功"   >> ${user_add_log}
    fi
}
#新增不带家目录的用户，在新增用户的时候没有输入了密码，代表用户nologin
function add_no_home(){
    local user=$1
    ssh -p ${port} root@${ip} "useradd -M $user -s /bin/nologin" < /dev/null
    if [ $? -eq 0 ];then
        printf "$(date "+%F %H:%M:%S") 在服务器 %s 中添加无密码不能登录的用户 %s 成功. \n" ${ip} $user 
        echo -e " ${ip}\t $user\t\t NONE\t\t $(date "+%F %H:%M:%S")\t\t 新增用户成功"   >> ${user_add_log}
    fi
}
#删除用户
function del(){
    local user=$1
    local ip=$2
    local port=$3
    ssh -p ${port} root@${ip} "userdel -r $user" < /dev/null
    printf "$(date "+%F %H:%M:%S") 在服务器%s中删除用户 %s 成功.\n" ${ip} $user
    echo -e " ${ip}\t $user\t\t $(date "+%F %H:%M:%S")\t\t 删除用户成功"   >> ${user_del_log}
    row=$(awk -v user=${user} '$2==user{print NR}' ${user_add_log})
    sed -i "${row}d" ${user_add_log}
}
function help(){
    echo " "
    echo "    增加单个有密码的用户: $0 add s 用户名 目标服务器 用户密码"
    echo "    增加单个随机密码的用户: $0 add s 用户名 目标服务器 password"
    echo "    增加单个无密码的用户: $0 add s 用户名 目标服务器 "
    echo "    批量增加有规律有密码的用户: $0 add m 用户名前缀 目标服务器 增加数量 密码|password."
    echo "            说明：密码关键字，会给所有增加的用户设置同一个密码；password关键字，会给所有增加的用户设置随机8位密码"
    echo " "
    echo "    批量增加用户: $0 add f 用户列表文件 目标服务器 . 用户列表文件说明,密码可以为空，格式是 : 用户名 密码"
    echo "    删除用户: $0 del s 用户名 目标服务器 "
    echo "    删除用户: $0 del f 用户列表文件 目标服务器"
    echo "    使用帮助: $0 help"
    echo " "
}

function empty_user(){
    local user=$1
    if [ -z $user ];then
        help
        exit 1
    fi
}
function empty_server(){
    local ip=$1
    local col=$(echo $ip|awk -F':' '{print NF}')
    if [ -z $server ];then
        help
        exit 1
    elif [ $col -ne 2 ];then
        server="${ip}:22"
    fi
}
#--------------------变量区-----------------------#
action=$1
param=$2
userlist=$3
server=$4
user_add_log="$(pwd)/user_add.log"
user_del_log="$(pwd)/user_del.log"
user_err_log="$(pwd)/user_err.log"
#--------------------流程区-----------------------#
if [ $UID -ne 0 ] ;then
    echo “必须使用超级管理员运行这个脚本”
    exit 1 
fi
empty_user $userlist
empty_server $server
case $action in
    add) 
        case $param in
            s)
                password=$5
                ip=$(echo $server|cut -d : -f1)
                port=$(echo $server|cut -d : -f2)
                if [ -z "$password" ];then
                    username_rule_check=$(check_username ${userlist})
                    user_exist_check=$(check_user_exist ${userlist} ${ip} ${port})
                    if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                        printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${userlist} $userlist
                        add_no_home $userlist ${ip} ${port}
                    else
                        printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${userlist}
                        echo -e " $userlist\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                    fi
                elif [ ! -z "$password" ] && [ $password == "password" ];then
                    passwd=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c8)
                    username_rule_check=$(check_username ${userlist})
                    user_exist_check=$(check_user_exist ${userlist} ${ip} ${port})
                    if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                        printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${userlist} $userlist
                        add_home $userlist $passwd ${ip} ${port}
                    else
                        printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${userlist}
                        echo -e " $userlist\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                    fi
                elif [ ! -z "$password" ] && [ $password != "password" ];then
                    username_rule_check=$(check_username ${userlist})
                    user_exist_check=$(check_user_exist ${userlist} ${ip} ${port})
                    if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                        printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${userlist} $userlist
                        add_home $userlist $password ${ip} ${port}
                    else
                        printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${userlist}
                        echo -e " $userlist\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                    fi
                fi
              ;;
            m)
                add_number=$5
                password=$6
                ip=$(echo $server|cut -d : -f1)
                port=$(echo $server|cut -d : -f2)
                echo ${add_number}|grep "^[0-9]*[1-9][0-9]*$" > /dev/null
                if [ $? -ne 0 ];then
                    echo "增加的用户数量必须是正整数"
                    exit 1
                fi
                pre_num=$(ssh -p ${port} root@${ip} "grep '"$userlist"' /etc/passwd|tail -n 1"|awk -F':' '{print $1}'|tr -cd "[0-9]" )
                for i in $(seq 1 "$add_number");do
                    if [ -z "$pre_num" ];then
                        pre_num=0
                    fi
                    new_i=$(($pre_num+$i))
                    user=${userlist}${new_i}
                    if [ -z $password ];then
                        echo "批量增加有规则的用户必须输入密码或者输入password关键参数，未输入参数自动更证参数为password"
                        password="password"
                    fi
                    if [ ! -z "$password" ] && [ $password == "password" ];then
                        passwd=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c8)
                        username_rule_check=$(check_username ${user})
                        user_exist_check=$(check_user_exist ${user} ${ip} ${port})
                        if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                            printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${user} $user
                            add_home $user $passwd ${ip} ${port}
                        else
                            printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${user}
                            echo -e " $user\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                        fi
                    elif [ ! -z "$password" ] && [ $password != "password" ];then
                        username_rule_check=$(check_username ${user})
                        user_exist_check=$(check_user_exist ${user} ${ip} ${port})
                        if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                            printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${user} $user
                            add_home $user $password ${ip} ${port}
                        else
                            printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${user}
                            echo -e " $user\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                        fi
                    fi
                done
              ;;
            f)
                if [ ! -f $userlist ];then
                    echo "输入的必须是一个用户列表文件！"
                    exit 1
                fi
                ip=$(echo $server|cut -d : -f1)
                port=$(echo $server|cut -d : -f2)
                awk '{print $1,$2}' $userlist|while read user password;do
                    if [ -z $password ];then
                        username_rule_check=$(check_username ${user})
                        user_exist_check=$(check_user_exist ${user} ${ip} ${port})
                        if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                            printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${user} $user
                            add_no_home $user ${ip} ${port} 
                        else
                            printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${user}
                            echo -e " $user\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                        fi
                    else
                        username_rule_check=$(check_username ${user})
                        user_exist_check=$(check_user_exist ${user} ${ip} ${port})
                        if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                            printf "在 %s 服务器上，将新增的用户名 %s 检测通过,准备新增用户 %s .\n" ${ip} ${userlist} $userlist
                            add_home $user $password ${ip} ${port} 
                        else
                            printf "在 %s 服务器上,新增用户 %s 的规则检测没有通过，或者用户已存在. \n" ${ip} ${user}
                            echo -e " $user\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 增加用户失败"   >> ${user_err_log}
                        fi
                    fi
                done
              ;;
            h)
                help
              ;;
            *)
                help
              ;;
        esac
      ;;
    del)
        case $param in
            s)
                ip=$(echo $server|cut -d : -f1)
                port=$(echo $server|cut -d : -f2)
                username_rule_check=$(check_username ${userlist})
                user_exist_check=$(check_user_exist ${userlist} ${ip} ${port})
                if [ ${username_rule_check} -eq 0 ] && [ ! -z ${user_exist_check} ];then
                    del $userlist ${ip} ${port}
                else
                    printf "在服务器 %s 删除用户 %s 规则检测没有通过，或者用户不存在.\n" $ip $userlist
                    echo -e " $userlist\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 删除用户失败"   >> ${user_err_log}
                fi
              ;;
            f)
                ip=$(echo $server|cut -d : -f1)
                port=$(echo $server|cut -d : -f2)
                if [ ! -f $userlist ];then
                    echo "输入的必须是一个用户列表文件！"
                    exit 1
                fi
                awk '{print $1}' $userlist|while read user;do
                username_rule_check=$(check_username ${user})
                user_exist_check=$(check_user_exist ${user} ${ip} ${port})
                if [ ${username_rule_check} -eq 0 ] && [ ! -z ${user_exist_check} ];then
                    del $user ${ip} ${port}
                else
                    printf "在服务器 %s 删除用户 %s 规则检测没有通过，或者用户不存在.\n" $ip $userlist
                    echo -e " $user\t\t $(date "+%F %H:%M:%S")\t\t ${ip}\t\t 删除用户失败"   >> ${user_err_log}
                fi
                done
              ;;
            help)
                help
              ;;
            *)
                help
              ;;
        esac
      ;;
    help)
        help
      ;;
    *)
        help
      ;;
esac
