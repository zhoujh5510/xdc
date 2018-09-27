#!/bin/bash

#this testcase is to atop some datanode

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_datanode.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_datanode.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_datanode.log

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_datanode.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_datanode.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_datanode.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_datanode.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_datanode.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_datanode.log

#stop datanode of 31
echo ">>>>>>>>stop datanode of 31 now " 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
EOF
echo "stop datanode of 31 successfully " 2>&1 | tee -a ./ha_log/stop_datanode.log


sleep 480
#start datanode of 31
echo ">>>>>>>>start datanode of 31 now " 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
EOF
echo "start datanode of 31 successfully " 2>&1 | tee -a ./ha_log/stop_datanode.log
echo ">>>>>>>>start datanode successfully" 2>&1 | tee -a ./ha_log/stop_datanode.log

#restart ESGYNDB
sleep 90 2>&1 | tee -a ./ha_log/stop_datanode.log
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_datanode.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_datanode.log

#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_datanode.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./ha_log/stop_datanode.log
else
	echo "this case is failed " | tee -a ./ha_log/stop_datanode.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_datanode.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_datanode.log
currenttime
cd ha_data
mv xdctest_select_31.log datanode_31.data
mv xdctest_select_57.log datanode_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./datanode.log
currenttime
