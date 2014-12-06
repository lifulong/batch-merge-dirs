#!/bin/bash

DEBUG="true"
INFO="true"

input_dir=$1
output_dir=$2

total_dirs=0
declare -a output_child_dirs


function DEBUG()
{
	if [ "$DEBUG" = "true" ]; then
		$@
	fi
}

function INFO()
{
	if [ "$INFO" = "true" ]; then
		$@
	fi
}

#----------------------------
#@params: dir want to check
#@return: 0 for ok, 1 not ok
#@author: lifulong
#----------------------------
function check_is_all_child_dirs()
{
	check_dir=$1

	[ ! -d $check_dir ] && { return 1; }

	for child in `ls $check_dir`
	do
		child_dir=${check_dir}"/"${child}
		if [ ! -d $child_dir ]; then
			return 1
		fi
	done

	return 0
}

#----------------------------
#@params: dir want to check
#@return: 0 for ok, 1 not ok
#@author: lifulong
#----------------------------
function check_is_all_child_files()
{
	check_dir=$1

	[ ! -d $check_dir ] && { return 1; }

	for child in `ls $check_dir`
	do
		child_file=${check_dir}"/"${child}
		if [ ! -f $child_file ]; then
			return 1
		fi
	done

	return 0
}

#-----------------------------
#@params: full dir
#@return: basename of dir path
#@author: lifulong
#-----------------------------
function get_dir_name()
{
	full_dir=$1
	#full_dir=${full_dir/%\//}

	dir_name=`basename $full_dir`

	echo $dir_name
}

#-----------------------------
#@params: dir name
#@return: add dir name to all_dirs
#@author: lifulong
#-----------------------------
function add_child_dir()
{
	getit=0
	child_dir=$1
	[ ! -d $child_dir ] && { return 1; }

	real_childdir=`get_dir_name $child_dir`

	for dir in ${output_child_dirs[@]}
	do
		if [ "$dir" = "$real_childdir" ]; then
			getit=1
			break
		fi
	done

	if [ $getit -eq 0 ]; then
		output_child_dirs[$total_dirs]=$real_childdir
		total_dirs=$[total_dirs+1]
	fi
}

#--------------------------
#params: top_dir
#return: get result
#recurse come true
#author: lifulong
#--------------------------
function get_child_dirs()
{
	local top_dir=$1

	[ ! -d $top_dir ] && { DEBUG echo "$top_dir is not dir."; return 1; }

	check_is_all_child_dirs $1
	if [ $? -eq 0 ]; then
		for child in `ls $top_dir`
		do
			get_child_dirs ${top_dir}"/"${child}
			[ $? -ne 0 ] && { return 1; }
		done
		return 0
	fi

	check_is_all_child_files $1
	[ $? -ne 0 ] && { return 1; }

	add_child_dir $top_dir

	return 0
}

#--------------------------
#@params: filename
#@return: filename ext
#@author: lifulong
#--------------------------
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

#--------------------------
#@params: num ext
#@return: filename
#@author: lifulong
#--------------------------
function mk_name()
{
	num="$1"
	ext=".$2"
	len=${#num}
	case $len in
		0) name="0000";;
		1) name="000"${num};;
		2) name="00"${num};;
		3) name="0"${num};;
		4) name=${num};;
		*) name="_error";;
	esac
	name=${name}${ext}
	echo $name
}

#--------------------------
#@params: from_dir to_dir
#@return: recurse implement
#@author: lifulong
#--------------------------
function do_rename()
{
	local from_dir=$1
	local to_dir=$2
	INFO echo "from_dir:$from_dir to_dir:$to_dir"
	check_is_all_child_files $from_dir
	if [ $? -eq 0 ]; then
		local base_fromdir=`basename $from_dir`
		local base_todir=`basename $to_dir`
		[ "$base_fromdir" != "$base_todir" ] && { return 0; }
		num=`ls -l $to_dir | wc -l`
		for fil in `ls $1`
		do
			ext=`get_ext $fil`
			name=`mk_name $num $ext`
			cp ${from_dir}"/"${fil} ${to_dir}"/"${name}
			num=$[num+1]
		done
	else
		check_is_all_child_dirs $from_dir
		if [ $? -eq 0 ]; then
			for dir in `ls $from_dir`
			do
				_from_dir=${from_dir}"/"${dir}
				do_rename $_from_dir $to_dir
				[ $? -ne 0 ] && { echo "return not zero:$?"; }
			done
		else
			echo "do_rename:error while deal $from_dir $to_dir."
			return 1
		fi
	fi

	return 0
}

#-----------------------
#@params: from top dir, dest dir
#@return: none
#@author: lifulong
#-----------------------
function batch_rename()
{
	top_dir=$1
	output_dir=$2

	[ ! -d $top_dir ] && return 1
	[ -d $output_dir ] && { rm -rf $output_dir; }
	[ ! -d $output_dir ] && { mkdir -p $output_dir; }

	for dir in ${output_child_dirs[@]}
	do
		INFO echo "Info: deal dir $dir ... ..."
		realdir=${output_dir}"/"${dir}
		mkdir -p $realdir
		do_rename $top_dir $realdir
	done
}

#set -x

echo "Starting get child dirs ... ..."
get_child_dirs $input_dir
echo "End get child dirs ... ..."
echo "Starting batch rename ... ..."
batch_rename $input_dir $output_dir
echo "End batch rename ... ..."


