#!/bin/bash

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_hbase.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_hbase.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_hbase.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_hbase.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee ./stop_hbase.log &
sleep 300 2>&1 | tee -a ./stop_hbase.log

#stop hbase of 31
echo "stop hbase of 31 now !!!!!" 2>&1 | tee -a ./stop_hbase.log
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./stop_hbase.log

sleep 480
#start hbase of 31
echo "start hbase now !!!!!" 2>&1 | tee -a ./stop_hbase.log
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./stop_hbase.log
echo "start hbase of 31 successfully !!!!!" 2>&1 | tee -a ./stop_hbase.log
sleep 90 2>&1 | tee -a ./stop_hbase.log

echo "start namenode successfully" 2>&1 | tee -a ./stop_zookeeper.log

sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_hbase.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_hbase.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_hbase.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_hbase.log
compare_xdc_test

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./stop_hbase.log


echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_hbase.log
