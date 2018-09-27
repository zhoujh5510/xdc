#!/bin/bash

#record time
starttime=`date +'%Y-%m-%d %H:%M:%S'`

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********"
}

function compare_xdc_test()
{	echo ">>>>>>>>compare data of table named xdc_test now !!!!!!"
	currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
	trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

	rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
	echo ">>>>>>>>compare data complete now "
	if [ $rt -le 2 ]; then
        	echo "The data in xdc_test on both DCs is the same ........."
		return 1
	else
		echo "The data in xdc_test on both DCs is not the same ........."
		return 0
	fi
}


echo ">>>>>>>>begin to exexute xdc_workload scripts now "
currenttime
sh ./xdc_workload.sh <<EOF
2
2000
n
EOF
starttime2=`date +'%Y-%m-%d %H:%M:%S'`
echo "prepare data time: $starttime2" | tee -a ./testtime.log

echo
echo ">>>>>>>>>>change file name now !!!!!!"
currenttime
mv ./prepare_1.sql ./old_prepare_1.sql
mv ./prepare_2.sql ./old_prepare_2.sql
mv ./dml_1.sql ./old_dml_1.sql
mv ./dml_2.sql ./old_dml_2.sql
echo
echo ">>>>>>>>change file name complete now !!!!!"
echo

#echo ">>>>>>>>run a backgroud process to kill xdc_workload1 "
#nohup sh ./kill_xdcworkload1.sh 2>&1 | tee ./kill_wokload1.log &
echo
echo

sleep 30

compare_xdc_test
#rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
if [ $? -eq 1 ];then
echo ">>>>>>>>begin to execute xdc_workload1 scripts now "
sh ./xdc_workload1.sh <<EOF
2
0
y
EOF
fi

echo
echo ">>>>>>>>xdc_workload completed "
currenttime
