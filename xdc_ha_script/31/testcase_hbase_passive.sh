#!/bin/bash

# this testcase is to stop hbase of passive DC

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_hbase_passive.log


#execute xdc_peer_check -d 5 -x 
currenttime
nohup sh ./check_57.sh | tee -a ./ha_log/stop_hbase_passive.log &


function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee ./ha_log/stop_hbase_passive.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_hbase_passive.log

#stop hbase of cluster 57
echo ">>>>>>>>stop hbase of cluster 57 now !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE 2>&1 | tee -a ./ha_log/stop_hbase_passive.log

sleep 480
#start hbase of cluster 57
echo
echo ">>>>>>>>start hbase of cluster 57 now !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
echo
echo ">>>>>>>>start hbase of 57 successfully !!!!!" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
sleep 90 2>&1 | tee -a ./ha_log/stop_hbase_passive.log

#restart ESGYNDB
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_hbase_passive.log

#excute xdc_peer_up -p 57
echo "kill xdc_peer_check and execute xdc_peer_up -p 57" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
sh ./kill_check_57.sh 2>&1 | tee -a ./ha_log/stop_hbase_passive.log


#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
        echo "this case is successfully " | tee -a ./ha_log/stop_hbase_passive.log
else
        echo "this case is failed " | tee -a ./ha_log/stop_hbase_passive.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill xdc_workload" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./ha_log/stop_hbase_passive.log

#rename the data file which selected from database for checking by human
currenttime
cd ha_data
mv xdctest_select_31.log hbase_passive_31.data
mv xdctest_select_57.log hbase_passive_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_hbase_passive.log
currenttime
