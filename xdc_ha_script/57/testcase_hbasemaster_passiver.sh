#!/bin/bash

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_hbasemaster_passive.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_hbasemaster_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_hbasemaster_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_hbasemaster_passive.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_hbasemaster_passive.log &
sleep 300 2>&1 | tee -a ./stop_hbasemaster_passive.log

#stop hbase master
echo "stop hbase master now" 2>&1 | tee -a ./stop_hbasemaster_passive.log
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop master"
EOF
echo "stop hbase master successfully " 2>&1 | tee -a ./stop_hbasemaster_passive.log

sleep 480
#start hbase master
echo "start hbase master  now !!!!!" 2>&1 | tee -a ./stop_hbasemaster_passive.log
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start master"
EOF
echo "start hbase master successfully " 2>&1 | tee -a ./stop_hbasemaster_passive.log
sleep 90  2>&1 | tee -a ./stop_hbasemaster_passive.log



echo "restart esgyndb now !!!!!"  2>&1 | tee -a ./stop_hbasemaster_passive.log
sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_hbasemaster_passive.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_hbasemaster_passive.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_hbasemaster_passive.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_hbasemaster_passive.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_hbasemaster_passive.log
else
	echo "this case is failed " | tee -a ./stop_hbasemaster_passive.log
fi

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh | tee -a ./stop_hbasemaster_passive.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_hbasemaster_passive.log
