#!/bin/sh
# RNDIS + ADB复合设备配置

# 设置要启用的USB功能 ( 按内核要求的顺序 ) 
USB_FUNCS="rndis adb"

# ADB实例配置
ADB_INSTANCES="ffs.adb"

# RNDIS实例配置
# 可选: 设置MAC地址
# RNDIS_ETHADDR="de:ad:be:ef:00:01"

# 加载默认环境变量
. /etc/profile