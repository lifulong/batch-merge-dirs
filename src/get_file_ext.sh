#!/bin/bash

#---------------------------
# @author	:	lifulong
# @date	:	2014.11.28
#---------------------------

# Only bash is supported.
[ $BASH ] || { echo "Bash is needed."; exit; }

Usage="Usage:`basename $0` filename"

[ $# -ne 1 ] && { echo $Usage; exit; }

function get_ext() {

	base_file_name=`basename $1`

	#声明数组，设置字符串分隔符，生成数组
	declare -a names
	IFS=.
	read -r -a names <<< "$base_file_name"

	#求取数组长度，返回数组最后一个元素
	num=$((${#names[*]}-1))
	echo ${names[$num]}
}


filename=$1

#返回字符串
echo $(get_ext $filename)

