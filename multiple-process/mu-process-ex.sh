#!/bin/bash

dir="/opt/data/file-test"
 
thread=4
tmp_fifofile="/tmp/$$.fifo"
mkfifo "$tmp_fifofile"
 
exec 10<>"$tmp_fifofile"

rm -f $tmp_fifofile
 
for ((i=0;i<$thread;i++));do
        echo >&10
done 
 
for i in a{1..50}
do
        read -u10
        {
        echo -e "\t I变量的值是$i,\t 脚本的进程号是$$,\t 父进程的ID是$PPID"
        sleep 1
        echo >&10
        } &
done
 
wait
exec 10>&-
exit 0
