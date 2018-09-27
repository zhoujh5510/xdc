#!/bin/bash

function compare_xdc_test()
{       echo ">>>>>>>>compare data of table named xdc_test now !!!!!!" 2>&1 | tee -a ./stop_regionserver.log
        trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s select_31.sql
        trafci.sh -h 10.10.23.57 -u db__root -p traf123 -s select_57.sql

        rt=$(diff ./xdctest_select_31.log ./xdctest_select_57.log | wc -l)
        echo ">>>>>>>>compare data complete now " 2>&1 | tee -a ./stop_regionserver.log
        if [ $rt -le 2 ]; then
                echo "The data in xdc_test on both DCs is the same ........." 2>&1 | tee -a ./stop_regionserver.log
                return 1
        else
                echo "The data in xdc_test on both DCs is not the same ........." 2>&1 | tee -a ./stop_regionserver.log
                return 0
        fi
}

#load data
nohup sh ./test_workload.sh 2>&1 | tee -a ./stop_regionserver.log &
sleep 300 2>&1 | tee -a ./stop_regionserver.log

#stop region server of 31
echo "stop region server" 2>&1 | tee -a ./stop_regionserver.log
su - root <<EOF
linux
sleep 2
sh /opt/trafodion/stop_regionserver_31.sh
EOF
echo "stop region server successfully " 2>&1 | tee -a ./stop_regionserver.log


sleep 480
#start namenode as start HDFS
echo "start namenode now !!!!!" 2>&1 | tee -a ./stop_regionserver.log
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE 2>&1 | tee -a ./stop_regionserver.log
sleep 90 2>&1 | tee -a ./stop_regionserver.log

echo "start region server successfully" 2>&1 | tee -a ./stop_regionserver.log

sh ./stop_esgyndb.sh 2>&1 | tee -a ./stop_regionserver.log
sh ./start_esgyndb.sh 2>&1 | tee -a ./stop_regionserver.log

#execute other operationsa
sleep 30 2>&1 | tee -a ./stop_regionserver.log
echo "begin to validate datas" 2>&1 | tee -a ./stop_regionserver.log
compare_xdc_test
if [ $? -eq 1 ];then
	echo "this case is successfully " | tee -a ./stop_regionserver.log
else
	echo "this case is failed " | tee -a ./stop_regionserver.log
fi

#kill the test_workload1.sh
sh ./kill_xdcworkload1.sh | tee -a ./stop_regionserver.log

echo ">>>>>>>>>>>>>>>>>>>>>>>>>this case is completed" 2>&1 | tee -a ./stop_regionserver.log
