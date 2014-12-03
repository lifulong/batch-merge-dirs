#!/bin/bash

#提供接口供其他程序调用

#------------------------
#@author:lifulong
#@date:2014.11.29
#Usage: . $0 || source $0 的方式import,提供接口调用
#------------------------


[ $BASH ] || { echo "Bash is needed."; exit; }

if [ -f "debug.sh" ]; then
	. debug.sh
fi

declare -a first_lvl_dirs
declare -a second_lvl_dirs
declare -a third_lvl_dirs


#---------------------
#@params: cfg file
#@return: is config file valid
#---------------------
function check_config ()
{
	[ $# -ne 1 ] && { echo "Usage:params error."; return 1; }

	[ ! -f $1 ] && { echo "Usage:params must be an valid file."; return 2; }

	exec 3<>$1
	
	while read raw_input_line<&3
	do
		DEBUG echo $raw_input_line
		if [ $raw_input_line == "" ]; then
			return 1
		fi
	done

	exec 3<&-
	exec 3>&-

	return 0
}

#---------------------
#@params: cfg file
#@return: is parse ok
#---------------------

function parse_config ()
{
	[ $# -ne 1 ] && { echo "Usage:parse_config need one config file parameters."; return 1; }

	ret=0

	exec 3<>$1

	while read raw_input_line<&3
	do
		DEBUG echo $raw_input_line
		if [ "$raw_input_line" == "" ]; then
			continue
		fi
		IFS=':' read cfg_name cfg_value <<-END_OF_LINE
			$raw_input_line
		END_OF_LINE
		DEBUG echo $cfg_name
		DEBUG echo $cfg_value

		case $cfg_name in
		first_level_dirs) [ "$cfg_value" = "" ] && continue
			IFS='@' read -r -a first_lvl_dirs <<< "$cfg_value"
			;;
		second_level_dirs) [ "$cfg_value" = "" ] && continue
			IFS='@' read -r -a second_lvl_dirs <<< "$cfg_value"
			;;
		third_level_dirs) continue;;
		base_dir) [ "$cfg_value" = "" ] && continue
			base_dir=$cfg_value;;
		file_nums) [ "cfg_value" = "" ] && continue
			file_nums=$cfg_value;;
		ext) [ "cfg_value" = "" ] && continue
			ext=$cfg_value;;
		esac

	done

	exec 3<&-
	exec 3>&-

	len1=${#first_lvl_dirs[*]}
	len2=${#second_lvl_dirs[*]}

	[ $len1 -eq 0 -o $len2 -eq 0 ] && ret=1

	INFO echo ${first_lvl_dirs[*]}
	INFO echo ${second_lvl_dirs[*]}

	return $ret
}

function create_files ()
{
	len1=${#first_lvl_dirs[@]}
	len2=${#second_lvl_dirs[@]}

	[ $len1 -eq 0 -o $len2 -eq 0 ] && return 1

	if [ "$base_dir" = "" ]; then
		base_dir="../data/"
	fi

	if [ "$ext" = "" ]; then
		ext=".png"
	fi

	if [[ $file_nums -eq 0 || $file_nums -gt 26 ]]; then
		file_nums=10
	fi
	if [ "$file_nums" = "" ]; then
		file_nums=10
	fi

	declare -a names=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'w')
	names[$file_nums]="0"
	
	for dir in ${first_lvl_dirs[@]}
	do
		fir_dir=${base_dir}${dir}
		[ ! -d "$fir_dir" ] && { mkdir -p "$fir_dir"; }

		for dir2 in ${second_lvl_dirs[@]}
		do
			sec_dir=${fir_dir}"/"${dir2}
			[ ! -d $sec_dir ] && { mkdir -p $sec_dir; }

			for fil_nam in ${names[@]}
			do
				if [ "$fil_nam" = "0" ]; then
					break
				fi
				file_name=${sec_dir}"/"${fil_nam}${ext}
				INFO echo $file_name
				[ ! -f $file_name ] && { touch $file_name; }
			done

		done

	done

	return 0
}


