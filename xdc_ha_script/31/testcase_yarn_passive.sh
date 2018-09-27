#!/bin/bash

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./stop_yarn_passive.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_yarn_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_yarn_passive.log

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_yarn_passive.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_yarn_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_yarn_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_yarn_passive.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee ./stop_yarn_passive.log &
sleep 300 2>&1 | tee -a ./stop_yarn_passive.log

#stop yarn of 57
echo ">>>>>>>>stop YARN of cluster 57 now !!!!!" 2>&1 | tee -a ./stop_yarn_passive.log
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/YARN 2>&1 | tee -a ./stop_yarn_passive.log

sleep 480
#start yarn of 57
echo ">>>>>>>>start YARN of cluster 57 now !!!!!" 2>&1 | tee -a ./stop_yarn_passive.log
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/YARN 2>&1 | tee -a ./stop_yarn_passive.log
echo "start YARN of 57 successfully !!!!!" 2>&1 | tee -a ./stop_yarn_passive.log
sleep 90 2>&1 | tee -a ./stop_yarn_passive.log

echo ">>>>>>>>start YARN successfully" 2>&1 | tee -a ./stop_yarn_passive.log

#restart ESGYNDB
echo ">>>>>>>>restart ESGYNDB" 2>&1 | tee -a ./stop_yarn_passive.log
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./stop_yarn_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./stop_yarn_passive.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_yarn_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./stop_yarn_passive.log
compare_xdc_test

#kill the test_workload1.sh
echo ">>>>>>>>kill xdc_workload" 2>&1 | tee -a ./stop_yarn_passive.log
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./stop_yarn_passive.log


echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_yarn_passive.log
