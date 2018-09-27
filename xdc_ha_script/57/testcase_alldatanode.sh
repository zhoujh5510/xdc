#!/bin/bash

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_alldatanode.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_alldatanode.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_alldatanode.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_alldatanode.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_alldatanode.log &
sleep 300 2>&1 | tee -a ./stop_alldatanode.log

#stop datanode of 31
echo ">>>>>>>>stop datanode of 31" 2>&1 | tee -a ./stop_alldatanode.log
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
EOF
echo "stop datanode of 31 successfully " 2>&1 | tee -a ./stop_alldatanode.log

#stop datanode of 32
echo "begin to stop datanode of 32 now " 2>&1 | tee -a ./stop_alldatanode.log
sh /opt/trafodion/stop_datanode_32.sh 2>&1 | tee -a ./stop_alldatanode.log
echo "stop datanode of 32 successfully " 2>&1 | tee -a ./stop_alldatanode.log


sleep 480
#start datanode
echo "start datanode of 31  now !!!!!" 2>&1 | tee -a ./stop_alldatanode.log
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
EOF
echo "start datanode of 31 successfully " 2>&1 | tee -a ./stop_alldatanode.log
echo "start datanode of 32  now !!!!!" 2>&1 | tee -a ./stop_alldatanode.log
sh /opt/trafodion/start_datanode_32.sh 2>&1 | tee -a ./stop_alldatanode.log
echo "start datanode of 32 successfully "  2>&1 | tee -a ./stop_alldatanode.log

echo "start All Data Node  successfully "  2>&1 | tee -a ./stop_alldatanode.log
sleep 90  2>&1 | tee -a ./stop_alldatanode.log



echo "restart esgyndb now !!!!!"  2>&1 | tee -a ./stop_alldatanode.log
sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_alldatanode.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_alldatanode.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_alldatanode.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_alldatanode.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_alldatanode.log
else
	echo "this case is failed " | tee -a ./stop_alldatanode.log
fi

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh | tee -a ./stop_alldatanode.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_alldatanode.log
