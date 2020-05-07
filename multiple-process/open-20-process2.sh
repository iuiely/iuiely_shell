#!/bin/bash

for ((i=1;i<=20;i++));do
    {
    echo -e "\t 名字是$i,\t 脚本的进程号是$$,\t 父进程的ID是$PPID"
    sleep 8
    } &
done
wait
