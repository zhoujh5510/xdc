#!/bin/bash

# this testcase is to stop namenode

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_namenode.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_namenode.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_namenode.log

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_namenode.log
        currenttime
	trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_namenode.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_namenode.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_namenode.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee -a ./ha_log/stop_namenode.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_namenode.log

#stop hdfs namenode
echo ">>>>>>>>stop hdfs namenode now" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh stop namenode"
EOF
echo "stop hdfs namenode successfully " 2>&1 | tee -a ./ha_log/stop_namenode.log

sleep 480
#start hdfs namenode
echo ">>>>>>>>start hdfs namenode  now !!!!!" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh start namenode"
EOF
echo ">>>>>>>>start hdfs namenode successfully " 2>&1 | tee -a ./ha_log/stop_namenode.log
sleep 90  2>&1 | tee -a ./ha_log/stop_namenode.log

#restart ESGYNDB
echo ">>>>>>>>restart esgyndb now !!!!!"  2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_namenode.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_namenode.log

#execute other operations
sleep 45 2>&1 | tee -a ./ha_log/stop_namenode.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./ha_log/stop_namenode.log
else
	echo "this case is failed " | tee -a ./ha_log/stop_namenode.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
sh ./kill_xdcworkload1.sh | tee -a ./ha_log/stop_namenode.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
cd ha_data
mv xdctest_select_31.log namenode_31.data
mv xdctest_select_57.log namenode_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_namenode.log
currenttime
