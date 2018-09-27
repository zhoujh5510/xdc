#!/bin/bash

# this testcase is to kill all zookeeper server

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_zookeeper.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_zookeeper.log

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
	currenttime
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_zookeeper.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_zookeeper.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_zookeeper.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee ./ha_log/stop_zookeeper.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_zookeeper.log

#stop all zookeeper componenets
echo ">>>>>>>>begin to stop all zookeeper components now " 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/ZOOKEEPER 2>&1 | tee -a ./ha_log/stop_zookeeper.log
echo
echo "stop all zookeeper components successfully !!!!" 2>&1 | tee -a ./ha_log/stop_zookeeper.log


sleep 480
#start all zookeeper components
echo ">>>>>>>>start all zookeeper compnents !!!!!" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/ZOOKEEPER 2>&1 | tee -a ./ha_log/stop_zookeeper.log
echo
echo ">>>>>>>>start all zookeeper components successfully !!!!" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
sleep 90 2>&1 | tee -a ./ha_log/stop_zookeeper.log

#restart esgyndb
echo "restart ESGYNDB now" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_zookeeper.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_zookeeper.log

#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_zookeeper.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
        echo "this case is successfully " 2>&1 | tee -a ./ha_log/stop_zookeeper.log
else
        echo "this case is failed " 2>&1 | tee -a ./ha_log/stop_zookeeper.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./ha_log/stop_zookeeper.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
cd ha_data
mv xdctest_select_31.log zookeeper_31.data
mv xdctest_select_57.log zookeeper_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_zookeeper.log
currenttime
