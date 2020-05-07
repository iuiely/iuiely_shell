#!/bin/bash

for i in $(cat aaa);do
    {
    echo -e "\t 名字是$i,\t 脚本的进程号是$$,\t 父进程的ID是$PPID"
    sleep 8
    } &
done
wait
