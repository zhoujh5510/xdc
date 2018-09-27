#!/bin/bash

#this testcase is to stop all regionserver of passive DC

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

#execute xdc_peer_check -d 5 -x on active DC 31
currenttime
nohup sh ./check_57.sh | tee -a ./ha_log/stop_allregionserver_passive.log &

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

#stop all region server Passive DC 57
currenttime
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/stop_allregionserver_57.sh" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

sleep 480
#start all region server of passive DC 57
currenttime
pdsh -w 10.10.23.57 "sh /opt/trafodion/xdc_HA_script/start_allregionserver_57.sh" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

sleep 90 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

#restrat esgyndb
echo ">>>>>>>>begin to restart ESGYNDB now" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
currenttime
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

#excute xdc_peer_up -p 57
echo ">>>>>>>>kill the process of xdc_peer_check and execute xdc_peer_up -p 57"
currenttime
sh ./kill_check_57.sh 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log

#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
        echo "this case is successfully " | tee -a ./ha_log/stop_allregionserver_passive.log
else
        echo "this case is failed " | tee -a ./ha_log/stop_allregionserver_passive.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill xdc_workload" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_allregionserver_passive.log

#rename the data file name which selected from database for checking by human
currenttime
cd ha_data
mv xdctest_select_31.log allregionserver_passive_31.data
mv xdctest_select_57.log allregionserver_passive_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_allregionserver_passive.log
currenttime
