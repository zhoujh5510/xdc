#!/bin/bash

#this test is to stop hbase master of passive DC

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

#execute xdc_peer_check -d 5 -x
currenttime
nohup sh ./check_57.sh | tee -a ./ha_log/stop_hbasemaster_passive.log &

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
                return 0
        fi
}

#load data
clear
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log &
currenttime
sleep 300 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

#stop hbase master of cluster 57
currenttime
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/stop_hbasemaster_57.sh" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

sleep 480
currenttime
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/start_hbasemaster_57.sh" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

sleep 90  2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

#restart ESGYNDB
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log

#excute xdc_peer_up -p 31
echo ">>>>>>>>kill xdc_peer_check and execute xdc_peer_up -p 57" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
sh ./kill_check_57.sh 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log


#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./ha_log/stop_hbasemaster_passive.log
else
	echo "this case is failed " | tee -a ./ha_log/stop_hbasemaster_passive.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill xdc_workload" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_hbasemaster_passive.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
cd ha_data
mv xdctest_select_31.log hbasemaster_passive_31.data
mv xdctest_select_57.log hbasemaster_passive_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_hbasemaster_passive.log
currenttime
