#!/bin/bash

# 获取根分区磁盘使用率
get_rootfs_space(){
  current_space=$(sudo df -Th | awk -F '[ %]' '{if ($NF=="/") print $(NF-2)}')
  echo "$current_space"
}

# 根据传入的名称获取该分区磁盘使用情况
get_fs_space(){
  current_space=$(sudo df -Th | awk -F '[ %]' '{if ($NF=="'"$1"'") print $(NF-2)}')
  echo "$current_space"
}

# 获取cpu 空闲率
get_cpu_used(){
  cpu_idle=$(sudo vmstat | awk '{print $(NF-2)}' | tail -n 1)
  echo "$cpu_idle"
}

# 获取内存使用情况
get_mem_used(){
#  mem_used=$(free -m | awk 'NR==2{print $NF}')            # 获取可用内存（单位MB）
  mem_used=$(sudo free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')    # 获取内存使用率百分比
  echo "$mem_used"
}

# 自动发现磁盘的DDL宏原型（用法参考zabbix官方文档）
fs_discover(){
  fsdisk=$(df -Th | grep -Ei 'ext|xfs' | awk '{print $NF}')
  echo -e "{\"data\":[\c"
  c=1
  for fs in $(echo "$fsdisk");do
    echo -e "{\"{#FSDISK}\":\"$fs\"}\c"
    if [[ $c -ne $(echo "$fsdisk" | wc -w) ]];then echo -e ",\c";fi
    c=$((c+1))
  done
  echo -e "]}\c"
}

# 入口
case $1 in
  get_rootfs_space)
    get_rootfs_space
  ;;
  get_cpu_used)
    get_cpu_used
  ;;
  get_mem_used)
    get_mem_used
  ;;
  fs_discover)
    fs_discover
  ;;
  get_fs_space)
    get_fs_space $2
  ;;
esac