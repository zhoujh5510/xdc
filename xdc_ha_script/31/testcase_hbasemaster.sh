#!/bin/bash

#thus case is to stop hbase mater of ACTIVE DC

function currenttime()
{
	echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbasemaster.log

#execute xdc_peer_check -d 5 -x
currenttime
nohup sh ./check.sh | tee -a ./ha_log/stop_hbasemaster.log &

function compare_xdc_test()
{       
	currenttime
	echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_hbasemaster.log

#stop hbase master
echo ">>>>>>>>stop hbase master now" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop master"
EOF
echo "stop hbase master successfully " 2>&1 | tee -a ./ha_log/stop_hbasemaster.log

sleep 480
#start hbase master
echo ">>>>>>>>start hbase master  now !!!!!" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start master"
EOF
echo "start hbase master successfully " 2>&1 | tee -a ./ha_log/stop_hbasemaster.log

#restart ESGYNDB
sleep 90  2>&1 | tee -a ./ha_log/stop_hbasemaster.log
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster.log

#excute xdc_peer_up -p 31
echo ">>>>>>>>kill the process of xdc_peer_check and execute xdc_peer_up -p 31" | tee -a ./ha_log/stop_hbasemaster.log
currenttime
sh ./kill_check.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster.log


#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./ha_log/stop_hbasemaster.log
else
	echo "this case is failed " | tee -a ./ha_log/stop_hbasemaster.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" | tee -a ./ha_log/stop_hbasemaster.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_hbasemaster.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" | tee -a ./ha_log/stop_hbasemaster.log
currenttime
cd ha_data
mv xdctest_select_31.log hbasemaster_31.data
mv xdctest_select_57.log hbasemaster_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_hbasemaster.log
currenttime
