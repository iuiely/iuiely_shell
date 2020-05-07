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
 
for i in a{1..100}
do
        read -u10
        {
        mkdir -p $dir/$i
        for j in c{1..100}
        do
                dd if=/dev/zero of=$dir/$i/$j bs=4096 count=1 > /dev/null 2>&1
        done
 
        echo >&10
 
        } &
done
 
wait
exec 10>&-
exit 0
