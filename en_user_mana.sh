#!/bin/bash
#author:iuiely
#增强的用户管理脚本
#-------------------------------------------------#
#检测新增用户名规则，用户名长度3到10位，必须由大小写字母、数字、下划线组成
function check_username(){
    local username=$1
    echo ${username}|grep "^[a-zA-Z0-9_]\{3,10\}$" > /dev/null
    echo $?
}
#检测新增的用户是否已存在
function check_user_exist(){
    local user=$1
    awk -F':' -v user=${user} '$1==user{print NR}' /etc/passwd
}

#新增带家目录的用户，在新增用户的时候输入了密码，代表用户有login权限
function add_home(){
    local user=$1
    local password=$2
    useradd $user
    if [ $? -eq 0 ];then
        echo "$user:$password" | chpasswd
        printf "$(date "+%F %H:%M:%S") 添加有密码可登录的用户%s成功，用户密码是 %s\n" $user $password
    fi
}
#新增不带家目录的用户，在新增用户的时候没有输入了密码，代表用户nologin
function add_no_home(){
    local user=$1
    useradd -M $user -s /bin/nologin
    if [ $? -eq 0 ];then
        printf "$(date "+%F %H:%M:%S") 添加无密码不能登录的用户%s成功. \n" $user 
    fi
}
function del(){
    local user=$1
    userdel -r $user 
    printf "$(date "+%F %H:%M:%S") 删除用户 %s 成功.\n" $user
}
function help(){
    echo " "
    echo "    增加单个有密码的用户: $0 add 用户名 用户密码"
    echo "    增加单个无密码的用户: $0 add 用户名"
    echo "    批量增加用户: $0 add 用户列表文件 . 用户列表文件说明,密码可以为空，格式是 : 用户名 密码"
    echo "    删除用户: $0 del 用户名"
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
#-------------------------------------------------#

action=$1
userlist=$2
if [ $UID -ne 0 ] ;then
    echo “必须使用超级管理员运行这个脚本”
    exit 1 
fi
case $action in
    add) 
        empty_user $userlist
        if [ ! -f $userlist ];then
            password=$3
            if [ -z $password ];then
                username_rule_check=$(check_username ${userlist})
                user_exist_check=$(check_user_exist ${userlist})
                if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                    printf "将新增的用户名检测通过,准备新增用户 %s .\n" $userlist
                    add_no_home $userlist
                else
                    printf "新增用户 %s 规则检测没有通过，或者用户已存在. \n" $userlist
                fi
            else
                username_rule_check=$(check_username ${userlist})
                user_exist_check=$(check_user_exist ${userlist})
                if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                    printf "将新增的用户名检测通过,准备新增用户 %s .\n" $userlist
                    add_home $userlist $password
                else
                    printf "新增用户 %s 规则检测没有通过，或者用户已存在. \n" $userlist
                fi
            fi
        elif [ -f $userlist ];then
            awk '{print $1,$2}' $userlist|while read user password;do
                if [ -z $password ];then
                    username_rule_check=$(check_username ${user})
                    user_exist_check=$(check_user_exist ${user})
                    if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                        printf "将新增的用户名检测通过,准备新增用户 %s .\n" $userlist
                        add_no_home $user
                    else
                        printf "新增用户 %s 规则检测没有通过，或者用户已存在. \n" $user
                    fi
                else
                    username_rule_check=$(check_username ${user})
                    user_exist_check=$(check_user_exist ${user})
                    if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                        printf "将新增的用户名检测通过,准备新增用户 %s .\n" $userlist
                        add_home $user $password
                    else
                        printf "新增用户 %s 规则检测没有通过，或者用户已存在.\n" $user
                    fi
                    
                fi
            done
        fi
      ;;
    del)
        empty_user $userlist
        del $userlist
      ;;
    help)
        help
      ;;
    *)
        help
      ;;
esac
