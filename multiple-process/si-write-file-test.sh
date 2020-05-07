#!/bin/bash

dir="/opt/data/file-test"
for i in a{1..100}
do
        mkdir -p $dir/$i
        for j in b{1..100}
        do
            dd if=/dev/zero of=$dir/$i/$j bs=4096 count=1 > /dev/null 2>&1
        done
done 
