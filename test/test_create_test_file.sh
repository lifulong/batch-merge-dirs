#!/bin/bash

DEBUG="false"
INFO="true"

[ $# -ne 1 ] && { echo "Usage:One config file needed."; exit; }

if [ -f "./../tools/debug.sh" ]; then
	. ../tools/debug.sh
fi

if [ -f "../tools/create_test_files.sh" ]; then
	. ../tools/create_test_files.sh
fi

#set -x
#unset -x

parse_config $1

create_files


