#!/bin/bash

# this case is to stop hbase

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_hbase.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbase.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbase.log


#execute xdc_peer_check -d 5 -x 
currenttime
nohup sh ./check.sh | tee -a ./ha_log/stop_hbase.log &


function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_hbase.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_hbase.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_hbase.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_hbase.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee ./ha_log/stop_hbase.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_hbase.log

#stop hbase of 31
echo ">>>>>>>>stop hbase of 31 now !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./ha_log/stop_hbase.log

sleep 480
#start hbase of 31
echo ">>>>>>>>start hbase now !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./ha_log/stop_hbase.log
echo ">>>>>>>>start hbase of 31 successfully !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase.log
sleep 90 2>&1 | tee -a ./ha_log/stop_hbase.log

#restart ESGYNDB 
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_hbase.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_hbase.log

#excute xdc_peer_up -p 31
echo "kill the process xdc_peer_check and execute xdc_peer_up -p 31" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
sh ./kill_check.sh 2>&1 | tee -a ./ha_log/stop_hbase.log


#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_hbase.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
        echo "this case is successfully " 2>&1 | tee -a ./ha_log/stop_hbase.log
else
        echo "this case is failed " 2>&1 | tee -a ./ha_log/stop_hbase.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./ha_log/stop_hbase.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
cd ha_data
mv xdctest_select_31.log hbase_31.data
mv xdctest_select_57.log hbase_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_hbase.log
currenttime
