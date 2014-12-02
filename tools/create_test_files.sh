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
		esac

	done

	exec 3<&-
	exec 3>&-

	len1=${#first_lvl_dirs[*]}
	len2=${#second_lvl_dirs[*]}

	[ $len1 -eq 0 -o $len2 -eq 0 ] && ret=1

	DEBUG echo ${first_lvl_dirs[*]}
	DEBUG echo ${second_lvl_dirs[*]}

	return $ret
}


