#!/bin/bash

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./stop_nodemanager_passive.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_nodemanager_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_nodemanager_passive.log

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_nodemanager_passive.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_nodemanager_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_nodemanager_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_nodemanager_passive.log
                return 0
        fi
}

#load data
clear
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_nodemanager_passive.log &
sleep 300 2>&1 | tee -a ./stop_nodemanager_passive.log

#stop nodemanager of 57
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/stop_nodemanager_57.sh" 2>&1 | tee -a ./stop_nodemanager_passive.log

sleep 480
#start nodemanager of 57
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/start_nodemanager_57.sh" 2>&1 | tee -a ./stop_nodemanager_passive.log 

sleep 90 2>&1 | tee -a ./stop_nodemanager_passive.log
#restart ESGYNDB
echo ">>>>>>>>restart ESGYNDB" 2>&1 | tee -a ./stop_yarn_passive.log
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./stop_yarn_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./stop_yarn_passive.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_nodemanager_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./stop_nodemanager_passive.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_nodemanager_passive.log
else
	echo "this case is failed " | tee -a ./stop_nodemanager_passive.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill xdc_workload" 2>&1 | tee -a ./stop_nodemanager_passive.log
sh ./kill_xdcworkload1.sh | tee -a ./stop_nodemanager_passive.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./nodemanager.log
