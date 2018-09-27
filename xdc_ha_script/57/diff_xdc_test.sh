#!/bin/bash

trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)

if [ $rt -eq 0 ]; then
	echo "equal $rt"
else
	echo "not equal $rt"
fi


echo "the result of compare data of xdc_test "
diff ./xdctest_select_31.log ./xdctest_select_57.log
