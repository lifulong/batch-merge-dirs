#!/bin/bash

#------------------------
#@author:lifulong
#@date:2014.11.29
#Usage: . $0 || source $0 的方式import,提供接口调用
#------------------------


[ $BASH ] || { echo "Bash is needed."; exit; }

#提供接口供其他程序调用

#Usage=$("Usage: `basename $0` configfile")
#[ $# -ne 1 ] && { echo $Usage; exit; }

declare -a first_level_dirs
declare -a second_level_dirs
declare -a third_level_dirs

function check_config ()
{
	echo "Nothing."
}

function parse_config ()
{
	[ $# -ne 1 ] && { echo "Usage:parse_config need one config file parameters."; exit; }

	exec 3<> $1

	while read raw_input_line<&3
	do
		echo $raw_input_line
	done

	exec 3<&-
	exec 3>&-

}


