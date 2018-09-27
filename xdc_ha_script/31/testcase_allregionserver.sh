#!/bin/bash

# this testcase is to stop all regionserver

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_allregionserver.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_allregionserver.log


#execute xdc_peer_check -d 5 -x
currenttime
nohup sh ./check.sh | tee -a ./ha_log/stop_allregionserver.log &


function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_allregionserver.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_allregionserver.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_allregionserver.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_allregionserver.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_allregionserver.log

#stop region server of 31
echo ">>>>>>>>stop region server of 31" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop regionserver"
EOF
echo "stop region server of 31 successfully " 2>&1 | tee -a ./ha_log/stop_allregionserver.log

#stop region server of 32
echo ">>>>>>>>begin to stop region server of 32 now " 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.32
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop regionserver"
exit
EOF
echo "stop region server of 32 successfully " 2>&1 | tee -a ./ha_log/stop_allregionserver.log


sleep 480
#start region server
echo ">>>>>>>>start region server of 31  now !!!!!" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
#curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
EOF
echo "start region server of 31 successfully " 2>&1 | tee -a ./ha_log/stop_allregionserver.log

echo ">>>>>>>>start region server of 32  now !!!!!" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.32
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
exit
EOF
echo "start region server of 32 successfully "  2>&1 | tee -a ./ha_log/stop_allregionserver.log

echo ">>>>>>>>start All  Region Server  successfully "  2>&1 | tee -a ./ha_log/stop_allregionserver.log
sleep 90  2>&1 | tee -a ./ha_log/stop_allregionserver.log

#restart ESGYNDB 
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_allregionserver.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_allregionserver.log

#excute xdc_peer_up -p 31
echo "kill the process xdc_peer_check and execute xdc_peer_up -p 31" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
sh ./kill_check.sh 2>&1 | tee -a ./ha_log/stop_allregionserver.log


#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_allregionserver.log
echo ">>>>>>>>begin to validate datas"
currenttime 
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./ha_log/stop_allregionserver.log
else
	echo "this case is failed " | tee -a ./ha_log/stop_allregionserver.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_allregionserver.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
cd ha_data
mv xdctest_select_31.log allregionserver_31.data
mv xdctest_select_57.log allregionserver_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_allregionserver.log
currenttime
