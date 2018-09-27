#!/bin/bash

#number of testcase
testcase_number=0

#success number of testcase
success_number=0

#failed number of testcase
failed_number=0

#get the start time of the script running
starttime=`date +'%Y-%m-%d %H:%M:%S'`

#function print_head_info will show the information of head
function print_head_info()
{
        echo "          -------------------------------------------------------------------------------------------" 2>&1 | tee ./Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./Result.log
        echo "          ----             This is the script of XDC HA test                                     ----" 2>&1 | tee -a ./Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./Result.log
        echo "          ----                Version: 1.0                                                       ----" 2>&1 | tee -a ./Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./Result.log
        echo "          ----                Author: jianhua.zhou@esgyn.cn                                      ----" 2>&1 | tee -a ./Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./Result.log
        echo "          ----                Date:   2018--09--10                                               ----" 2>&1 | tee -a ./Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./Result.log
        echo "          -------------------------------------------------------------------------------------------" 2>&1 | tee -a ./Result.log
}

#function print_end_info will show the result of testcase
function print_end_info()
{
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a ./Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./Result.log
        echo "                 Total TestCase: $testcase_number                                                    " 2>&1 | tee -a ./Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./Result.log
        echo "                 Total Success : $success_number                                                     " 2>&1 | tee -a ./Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./Result.log
        echo "                 Total Failed  : $failed_number                                                      " 2>&1 | tee -a ./Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./Result.log
        echo "                 Total RunTime : "$((end_seconds-start_seconds))"s                                   " 2>&1 | tee -a ./Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./Result.log
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a ./Result.log
}


#function of run testcase
#param 1: the name of file which executed
#param 2: the log of file which executed
#param 3: the name of testcase
function run_testcase()
{
        #testcase 1, stop all zookeeper server of passive DC
        let testcase_number=testcase_number+1
        echo  "************************** Test Case $testcase_number *********************************" 2>&1 | tee -a ./Result.log
        echo  "************************** $3 *********************************" 2>&1 | tee -a ./Result.log
        sh $1
        if [ `grep -c "this case is successfully" ./ha_log/$2` -ge '1' ]; then
                echo "************************* Test Case $testcase_number is successfully ********************" 2>&1 | tee -a ./Result.log
                let success_number=success_number+1
        else
                let failed_number=failed_number+1
                echo "************************* Test Case $testcase_number is failed ********************" 2>&1 | tee -a ./Result.log
        fi
        echo  "************************** Test Case $testcase_number is completed*********************************" 2>&1 | tee -a ./Result.log
        echo 2>&1 | tee -a ./Result.log
        echo 2>&1 | tee -a ./Result.log
}

#create directory named ha_log and ha_data
#mkdir ha_log
#mkdir ha_data
#mkdir ha_shell

#print_head_info
print_head_info

echo
echo
echo | tee -a ./Result.log
echo | tee -a ./Result.log
echo ">>>>>>>>>>>:The Start of Running Time: $starttime" 2>&1 | tee -a ./Result.log
echo | tee -a ./Result.log

#just for testing
#run_testcase test1.sh test1.log "test case number 1"
#run_testcase test2.sh test2.log "test case number 2"

#param 1: the name of file which executed
#param 2: the log of file which executed
#param 3: the name of testcase
#testcase 1 stop active hbase master of Active DC
run_testcase testcase_hbasemaster.sh stop_hbasemaster.log "stop active hbase master of Active DC"

#testcase 2 stop active zookeeper leader server of Active DC
run_testcase testcase_zookeeperleader.sh stop_zookeeperleader.log "stop active zookeeper leader server of Active DC"

#testcase 3 stop all zookeeper server of Active DC
run_testcase testcase_zookeeper.sh stop_zookeeper.log "stop all zookeeper server of Active DC"

#testcase 4 stop some region server of Active DC
run_testcase testcase_regionserver.sh stop_regionserver.log "stop some region server of Active DC"

#testcase 5 stop all region server of Active DC
run_testcase testcase_allregionserver.sh stop_allregionserver.log "stop all region server of Active DC"

#testcase 6 stop hbase of Active DC
run_testcase testcase_hbase.sh stop_hbase.log "stop hbase of Active DC"

#testcase 7 stop namenode of Active DC
run_testcase testcase_namenode.sh stop_namenode.log "stop namenode of Active DC"

#testcase 8 stop some datanode of Active DC
#run_testcase testcase_datanode.sh stop_datanode.log "stop some datanode of Active DC"

#testcase 9 stop all datanode of Active DC
#run_testcase testcase_alldatanode.sh stop_alldatanode.log "stop all datanode of Active DC"



#param 1: the name of file which executed
#param 2: the log of file which executed
#param 3: the name of testcase
#testcase 1 stop active hbase master of passive DC
#run_testcase testcase_hbasemaster_passive.sh stop_hbasemaster_passive.log "stop active hbase master of passive DC"

#testcase 2 stop namenode of passive DC
run_testcase testcase_namenode_passive.sh stop_namenode_passive.log "stop namenode of passive DC" 

#testcase 3 stop all zookeeper server of passive DC
run_testcase testcase_zookeeper_passive.sh stop_zookeeper_passive.log "stop all zookeeper server on passive DC"

#testcase 4 stop Some Regionserver of passive DC
run_testcase testcase_regionserver_passive.sh stop_regionserver_passive.log "stop some region server on passive DC"

#testcase 5 stop ALL Regionserver of passive DC
run_testcase testcase_allregionserver_passive.sh stop_allregionserver_passive.log "stop all region server on passive DC"

#testcase 6 stop hbase of passive DC
run_testcase testcase_hbase_passive.sh stop_hbase_passive.log "stop all hbase on passive DC"

#testcase 8 stop some datanode of Active DC
run_testcase testcase_datanode.sh stop_datanode.log "stop some datanode of Active DC"

#testcase 9 stop all datanode of Active DC
run_testcase testcase_alldatanode.sh stop_alldatanode.log "stop all datanode of Active DC"

#testcase 7 stop some datanode of passive DC
#this case is dangerous, should be executed at last
#run_testcase testcase_datanode_passive.sh stop_datanode_passive.log "stop some datanode on passive DC"

#testcase 8 stop all datanode of passive DC
#this case is dangerous, should be executed at last
#run_testcase testcase_alldatanode_passive.sh stop_alldatanode_passive.log "stop all datanode on passive DC"

#record the end time of this script
endtime=`date +'%Y-%m-%d %H:%M:%S'`
echo ">>>>>>>>>>>>>>:end time of this script is: $endtime" | tee -a ./Result.log
echo | tee -a ./Result.log

start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);

#total run time
echo ">>>>>>>>>>>>>:Total runtime is: "$((end_seconds-start_seconds))"s" | tee -a ./Result.log

#run fucntion print_end_info
print_end_info 

echo "The Result Of XDC test is in ./Result.log !!!!"
echo
echo "                ************************************************************************"




