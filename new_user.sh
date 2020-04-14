#!/bin/sh
#author:iuiely
#----------------------------------------------------------------#
#检测新增用户名规则，用户名长度3到10位，必须由大小写字母、数字、下划线组成
function check_username(){
    local username=$1
    echo ${username}|grep "^[a-zA-Z0-9_]\{3,10\}$" > /dev/null
    echo $?
}
#----------------------------------------------------------------#
#检测新增的用户是否已存在
function check_user_exist(){
    local user=$1
    awk -F':' -v user=${user} '$1==user{print NR}' /etc/passwd
}
#----------------------------------------------------------------#
#设置用户的密码
function set_password(){
    local user=$1
    local password=$2
    #如果密码为空，设置默认密码为123456
    if [ -z ${password} ];then
        local password="123456"
    fi
    echo "$user:$password"|chpasswd
}
#----------------------------------------------------------------#

USERLIST=$1
PASSWORD=$2
#检测准备新增用户信息,包括用户是字符串或者用户是文件
if [ $UID -ne 0 ];then
    echo “增加新用户需要有root权限!” 
    exit 1
fi
#开始新增用户逻辑,检测有没有输入用户名
if [ ! -z $USERLIST ];then
    #用户名不是文件的情况，新增用户逻辑
    if [ ! -f $USERLIST ];then
        #检测用户名情况
        username_rule_check=$(check_username ${USERLIST})
        user_exist_check=$(check_user_exist ${USERLIST})
        if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
            printf "将新增的用户名检测通过,准备新增用户 %s .\n" $USERLIST
            #开始新增用户，和给新增用户设置用户名和密码，新增的用户都有登录bash的权限
            useradd ${USERLIST}
            if [ $? -eq 0 ];then
                set_password ${USERLIST} $PASSWORD
                printf "Added user %s success.\n" $USERLIST
            fi
        else
            printf "User %s already exists. \n" $USERLIST
        fi
    #用户名是文件的情况，新增用户逻辑
    elif [ -f $USERLIST ];then
        awk '{print $1,$2}' $USERLIST|while read user password
        do
            #检测用户名情况
            username_rule_check=$(check_username ${user})
            user_exist_check=$(check_user_exist ${user})
            if [ ${username_rule_check} -eq 0 ] && [ -z ${user_exist_check} ];then
                printf "将新增的用户名检测通过,准备新增用户 %s .\n" $user
                #开始新增用户，和给新增用户设置用户名和密码，新增的用户都有登录bash的权限
                useradd ${user}
                if [ $? -eq 0 ];then
                    set_password ${user} $password
                    printf "Added user %s success.\n" $user
                fi
            else
                printf "User %s already exists. \n" $user
            fi
        done
    fi
fi
