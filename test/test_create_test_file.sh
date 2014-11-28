#!/bin/bash

[ $# -ne 1 ] && { echo "Usage:One config file needed."; exit; }

. ../tools/create_test_files.sh

parse_config $1

