#!/bin/bash

#this case is to kill the zookeeper leader of active DC

function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
}

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log

#get zookeeper leader, if you run this scripts in other clusters, you shoud change the ip address
#the zookeeper leader ip is stored in $i
for i in 10.10.23.31 10.10.23.32;
do
        echo status | nc $i 2181 > ./get_lead.log
        rt=$(grep -c "leader" ./get_lead.log)
        if [ $rt -eq 1 ];then
                break;
        fi
done

function compare_xdc_test()
{       
	echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
	currenttime
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./ha_data/xdctest_select_31.log ./ha_data/xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
                return 0
        fi
}

#load data
clear
currenttime
nohup sh ./test_workload.sh 2>&1 | tee ./ha_log/stop_zookeeperleader.log &
sleep 300 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log

#stop all zookeeper componenets
echo ">>>>>>>>begin to stop zookeeper Server leader in this cluster now " 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
echo
echo ">>>>>>>The leader of Zookeeper Server is in: $i" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
echo
#stop the zookeeper server of lead
su - root <<EOF
linux
ssh -T $i
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
exit
EOF
echo "stop zookeeper server leader is successfully " 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log


sleep 480
#start all zookeeper components
echo ">>>>>>>>start zookeeper server which has been down now !!!!!" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
echo
#start the zookeeper server of lead
su - root <<EOF
linux
ssh -T $i
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
exit
EOF
echo "start zookeeper server which has been down successfully !!!!" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
sleep 90 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log

#restart esgyndb
echo ">>>>>>>>rstart ESGYNDB now " 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
sh ./stop_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log

#execute other operationsa
sleep 45 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
compare_xdc_test
if [ $? -eq 1 ];then
        echo "this case is successfully " | tee -a ./ha_log/stop_zookeeperleader.log
else
        echo "this case is failed " | tee -a ./ha_log/stop_zookeeperleader.log
fi

#kill the test_workload1.sh
echo ">>>>>>>>kill the process of test_workload.sh, xdc_workload.sh, xdc_workload1.sh" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log

#mv the name of select data file
echo ">>>>>>>>change data file name which selected from database in ./ha_data" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
cd ha_data
mv xdctest_select_31.log zookeeperleader_31.data
mv xdctest_select_57.log zookeeperleader_57.data
cd ..

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./ha_log/stop_zookeeperleader.log
currenttime
