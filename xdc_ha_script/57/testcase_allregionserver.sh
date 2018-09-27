#!/bin/bash

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_allregionserver.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_allregionserver.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_allregionserver.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_allregionserver.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_allregionserver.log &
sleep 300 2>&1 | tee -a ./stop_allregionserver.log

#stop region server of 31
echo "stop region server of 31" 2>&1 | tee -a ./stop_allregionserver.log
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop regionserver"
EOF
echo "stop region server of 31 successfully " 2>&1 | tee -a ./stop_allregionserver.log

#stop region server of 32
echo "begin to stop region server of 32 now " 2>&1 | tee -a ./stop_allregionserver.log
sh /opt/trafodion/stop_regionserver_32.sh 2>&1 | tee -a ./stop_allregionserver.log
echo "stop region server of 32 successfully " 2>&1 | tee -a ./stop_allregionserver.log


sleep 480
#start region server
echo "start region server of 31  now !!!!!" 2>&1 | tee -a ./stop_allregionserver.log
#curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./stop_allregionserver.log
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
EOF
echo "start region server of 31 successfully " 2>&1 | tee -a ./stop_allregionserver.log
echo "start region server of 32  now !!!!!" 2>&1 | tee -a ./stop_allregionserver.log
sh /opt/trafodion/start_regionserver_32.sh 2>&1 | tee -a ./stop_allregionserver.log
echo "start region server of 32 successfully "  2>&1 | tee -a ./stop_allregionserver.log

echo "start All  Region Server  successfully "  2>&1 | tee -a ./stop_allregionserver.log
sleep 90  2>&1 | tee -a ./stop_allregionserver.log



echo "restart esgyndb now !!!!!"  2>&1 | tee -a ./stop_allregionserver.log
sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_allregionserver.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_allregionserver.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_allregionserver.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_allregionserver.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_allregionserver.log
else
	echo "this case is failed " | tee -a ./stop_allregionserver.log
fi

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh | tee -a ./stop_allregionserver.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_allregionserver.log
