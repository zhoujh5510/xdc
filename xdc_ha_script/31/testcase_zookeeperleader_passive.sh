#!/bin/bash

#delete data before execute this script
echo ">>>>>>Delet Data before execute this script....." 2>&1 | tee -a ./stop_zookeeperleader_passive.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_zookeeperleader_passive.log
trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s ./delete_data.sql 2>&1 | tee -a ./stop_zookeeperleader_passive.log

#get zookeeper leader, if you run this scripts in other clusters, you shoud change the ip address
#the zookeeper leader ip is stored in $i
for i in 10.10.23.57 10.10.23.58 10.10.23.59;
do
        echo status | nc $i 2181 > ./get_lead_57.log
        rt=$(grep -c "leader" ./get_lead_57.log)
        if [ $rt -eq 1 ];then
                break;
        fi
done

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_zookeeperleader_passive.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_zookeeperleader_passive.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_zookeeperleader_passive.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee ./stop_zookeeperleader_passive.log &
sleep 300 2>&1 | tee -a ./stop_zookeeperleader_passive.log

#stop zookeeper leader of DC 57
echo ">>>>>>>begin to stop zookeeper Server leader in cluster 57 now " 2>&1 | tee -a ./stop_zookeeperleader_passive.log
echo
echo "The leader of Zookeeper Server in cluster 57 is in: $i" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
echo
#stop the zookeeper server of leader
su - root <<EOF
linux
ssh -T $i
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
exit
EOF
echo ">>>>>>>>stop zookeeper server leader is successfully " 2>&1 | tee -a ./stop_zookeeperleader_passive.log


sleep 480
#start zookeeper leader of cluster 57
echo ">>>>>>>>start zookeeper server of cluster 57 which has been down now !!!!!" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
echo
#start the zookeeper server of lead
su - root <<EOF
linux
ssh -T $i
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
exit
EOF
echo ">>>>>>>>start zookeeper server which has been down successfully !!!!" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
sleep 90 2>&1 | tee -a ./stop_zookeeperleader_passive.log

#restart esgyndb
echo ">>>>>>>>restart the ESGYNDB at cluster 57" | tee -a ./stop_zookeeperleader_passive.log
sh ./stop_esgyndb_57.sh 2>&1 | tee -a ./stop_zookeeperleader_passive.log
sh ./start_esgyndb_57.sh 2>&1 | tee -a ./stop_zookeeperleader_passive.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_zookeeperleader_passive.log
echo ">>>>>>>>begin to validate datas" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
compare_xdc_test

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh 2>&1 | tee -a ./stop_zookeeperleader_passive.log


echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_zookeeperleader_passive.log
