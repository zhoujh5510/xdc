#!/bin/bash

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./stop_allnodemanager.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_allnodemanager.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_allnodemanager.log


function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_allnodemanager.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_allnodemanager.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_allnodemanager.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_allnodemanager.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_allnodemanager.log &
sleep 300 2>&1 | tee -a ./stop_allnodemanager.log

#stop nodemanager of 31
echo "stop nodemanager of 31" 2>&1 | tee -a ./stop_allnodemanager.log
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
EOF
echo "stop nodemanager of 31 successfully " 2>&1 | tee -a ./stop_allnodemanager.log

#stop nodemanager of 32
echo "begin to stop nodemanager of 32 now " 2>&1 | tee -a ./stop_allnodemanager.log
su - root <<EOF
linux
ssh -T 10.10.23.32
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
exit
EOF
echo "stop nodemanager of 32 successfully " 2>&1 | tee -a ./stop_allnodemanager.log


sleep 480
#start nodemanager
echo "start nodemanager of 31  now !!!!!" 2>&1 | tee -a ./stop_allnodemanager.log
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
EOF
echo "start nodemanager of 31 successfully " 2>&1 | tee -a ./stop_allnodemanager.log
echo
echo "start nodemanager of 32  now !!!!!" 2>&1 | tee -a ./stop_allnodemanager.log
su - root <<EOF
linux
ssh -T 10.10.23.32
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
exit
EOF
echo "start nodemanager of 32 successfully "  2>&1 | tee -a ./stop_allnodemanager.log

echo "start All  Node Manager  successfully "  2>&1 | tee -a ./stop_allnodemanager.log
sleep 90  2>&1 | tee -a ./stop_allnodemanager.log



echo "restart esgyndb now !!!!!"  2>&1 | tee -a ./stop_allnodemanager.log
sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_allnodemanager.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_allnodemanager.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_allnodemanager.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_allnodemanager.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_allnodemanager.log
else
	echo "this case is failed " | tee -a ./stop_allnodemanager.log
fi

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh | tee -a ./stop_allnodemanager.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_allnodemanager.log
