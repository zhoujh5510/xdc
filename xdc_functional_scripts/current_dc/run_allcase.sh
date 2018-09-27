#!/bin/bash

#nu=mber of test case
testcase_number=0

#the number of success, failed_number
success_number=0
failed_number=0

#get the start time of the script
starttime=`date +'%Y-%m-%d %H:%M:%S'`

#function print_head_info will show the information of head
function print_head_info()
{
        echo "          -------------------------------------------------------------------------------------------" 2>&1 | tee ./logs/Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----             This is the script of XDC functional test                             ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                Version: 1.0                                                       ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                Author: jianhua.zhou@esgyn.cn                                      ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                Date:   2018--08--28                                               ----" 2>&1 | tee -a ./logs/Result.log
        echo "          ----                                                                                   ----" 2>&1 | tee -a ./logs/Result.log
        echo "          -------------------------------------------------------------------------------------------" 2>&1 | tee -a ./logs/Result.log
}

function print_attention()
{
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "          ++++                                                                                   ++++"
        echo "          ++++             Precondition                                                          ++++"
        echo "          ++++                                                                                   ++++"
        echo "          ++++          1) Make Sure XDC Confiuration Completed And successfully                 ++++"
        echo "          ++++                                                                                   ++++"
        echo "          ++++          2) Make Sure ALL Hosts Can SSH Each Other successfully In Trafodion User ++++"
        echo "          ++++                                                                                   ++++"
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

#function print_end_info will show the result of testcase
function print_end_info()
{
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a ./logs/Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./logs/Result.log
        echo "                 Total TestCase: $testcase_number                                                    " 2>&1 | tee -a ./logs/Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./logs/Result.log
        echo "                 Total Success : $success_number                                                     " 2>&1 | tee -a ./logs/Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./logs/Result.log
        echo "                 Total Failed  : $failed_number                                                      " 2>&1 | tee -a ./logs/Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./logs/Result.log
        echo "                 Total RunTime : "$((end_seconds-start_seconds))"s                                   " 2>&1 | tee -a ./logs/Result.log
        echo "          ++++                                                                                   ++++" 2>&1 | tee -a ./logs/Result.log
        echo "          +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a ./logs/Result.log
}


#get active dc and passive dc ip address
function get_ip()
{
        echo -n "please enter the host number of cluster active DC:  " 2>&1 | tee -a ./logs/Result.log
        read dc1_num
        for((i=1;i<=$dc1_num;i++))
        do
                echo -n "please enter the $i ip addresses of cluster active DC(ip address like:10.10.23.31):  " 2>&1 | tee -a ./logs/Result.log
                read dc1_ip_$i
        done

        echo "The first ip address of ACTIVE DC is : $dc1_ip_1" 2>&1 | tee -a ./logs/Result.log
        echo -n "please enter the host number of cluster Passive DC:  " 2>&1 | tee -a ./logs/Result.log
        read dc1_num
        for((i=1;i<=$dc1_num;i++))
        do
                echo -n "please enter the $i ip addresses of cluster Passive DC(ip address like:$dc2_ip_1):  " 2>&1 | tee -a ./logs/Result.log
                read dc2_ip_$i
        done

        echo "The first ip address of ACTIVE DC is : $dc2_ip_1" 2>&1 | tee -a ./logs/Result.log
}

#function compare, compare the data in two tables
function compare()
{
        sql_name="/opt/trafodion/xdc_automatic/sql/compare.sql"
        log_name="/opt/trafodion/xdc_automatic/logs/compare_peer.log"
        mv_name="/opt/trafodion/xdc_automatic/logs/compare_current.log"
        log_dir="/opt/trafodion/xdc_automatic/logs/"

        #execute command on two clusters
        pdsh -w $dc1_ip_1,$dc2_ip_1 "sqlci -i  $sql_name | tee $log_name"

        #change current file name
        mv $log_name $mv_name

        #scp file which in other cluster to current cluster
        scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/compare_peer.log $log_dir

        #compare two files
        diff $log_name $mv_name > /dev/null
        if [ $? -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

#function compareXDC, compare the data in two tables named XDC
function compareXDC()
{
        sql_name="/opt/trafodion/xdc_automatic/sql/compare_xdc.sql"
        log_name="/opt/trafodion/xdc_automatic/logs/compare_peer_xdc.log"
        mv_name="/opt/trafodion/xdc_automatic/logs/compare_current_xdc.log"
        log_dir="/opt/trafodion/xdc_automatic/logs/"

        #execute command on two clusters
        pdsh -w $dc1_ip_1,$dc2_ip_1 "sqlci -i  $sql_name | tee $log_name"

        #change current file name
        mv $log_name $mv_name

        #scp file which in other cluster to current cluster
        scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/compare_peer_xdc.log $log_dir

        #compare two files
        diff $log_name $mv_name > /dev/null
        if [ $? -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

#function comparePt, compare the data in two tables named XDC4 which use partition
function comparePt()
{
        sql_name="/opt/trafodion/xdc_automatic/sql/compare_pt.sql"
        log_name="/opt/trafodion/xdc_automatic/logs/compare_peer_pt.log"
        mv_name="/opt/trafodion/xdc_automatic/logs/compare_current_pt.log"
        log_dir="/opt/trafodion/xdc_automatic/logs/"

        #execute command on two clusters
        pdsh -w $dc1_ip_1,$dc2_ip_1 "sqlci -i  $sql_name | tee $log_name"

        #change current file name
        mv $log_name $mv_name

        #scp file which in other cluster to current cluster
        scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/compare_peer_pt.log $log_dir

        #compare two files
        diff $log_name $mv_name > /dev/null
        if [ $? -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

#function comparexDC_test, compare the data in two tables named xDC_test
function compare_xDC_test()
{
        sql_name="/opt/trafodion/xdc_automatic/sql/compare_xDC_test.sql"
        log_name="/opt/trafodion/xdc_automatic/logs/compare_peer_xDC_test.log"
        mv_name="/opt/trafodion/xdc_automatic/logs/compare_current_xDC_test.log"
        log_dir="/opt/trafodion/xdc_automatic/logs/"

        #execute command on two clusters
        pdsh -w $dc1_ip_1,$dc2_ip_1 "sqlci -i  $sql_name | tee $log_name"

        #change current file name
        mv $log_name $mv_name

        #scp file which in other cluster to current cluster
        scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/compare_peer_xDC_test.log $log_dir

        #compare two files
        diff $log_name $mv_name > /dev/null
        if [ $? -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

#function compare_xdc_test, compare the data in two tables named xdc_test
function compare_xdc_test()
{
        sql_name="/opt/trafodion/xdc_automatic/sql/compare_XDC_TEST.sql"
        sql_name1="/opt/trafodion/xdc_automatic/sql/compare_xdc_test.sql"
        log_name="/opt/trafodion/xdc_automatic/logs/compare_peer_xdc_test.log"
        mv_name="/opt/trafodion/xdc_automatic/logs/compare_current_xdc_test.log"
        log_dir="/opt/trafodion/xdc_automatic/logs/"

        #execute command on two clusters
        pdsh -w $dc1_ip_1 "sqlci -i  $sql_name | tee $log_name"
        pdsh -w $dc2_ip_1 "sqlci -i  $sql_name1 | tee $log_name"

        #change current file name
        mv $log_name $mv_name

        #scp file which in other cluster to current cluster
        scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/compare_peer_xdc_test.log $log_dir

        #compare two files
        diff $log_name $mv_name > /dev/null
        if [ $? -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

#record current time fro logging
function currenttime()
{
        echo "******** $(date "+%Y-%m-%d %H:%M:%S" ) >>>> The Time Of Running This Step ********" 2>&1 | tee -a ./logs/$1
}


clear
#run function of print_head_info
print_head_info

echo
echo
echo
#print the information of attention
print_attention

#if you forgot configuration, you can use CTRL + c to stop script
echo "If you forget the above configuration, you can use CTRL + c to stop programm"
sleep 20

echo
echo
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

#get the host of active DC and passive DC
clear
get_ip

echo ">>>>>>>>>>>:The Start of Running Time: $starttime" | tee -a ./logs/Result.log
echo

echo ">>>>>>>>>>>:Create Directory Named logs For Storing logs" | tee -a ./logs/Result.log
mkdir -p /opt/trafodion/xdc_automatic/logs 2>&1 | tee -a ./logs/Result.log

echo ">>>>>>>>>>>:Copy Files Of current DC to Peer DC" | tee -a ./logs/Result.log
#copy files of current dir to peer dc /opt/trafodion/xdc_automatic
pdcp -w $dc2_ip_1 -r /opt/trafodion/xdc_automatic /opt/trafodion/ 2>&1 | tee -a ./logs/Result.log

echo "create schema xdc_test now !!!" | tee -a ./logs/Result.log
sqlci -i ./sql/create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/create_schema.sql" | tee -a ./logs/Result.log

#run test case 1
#Data can be insert into both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase1.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase1.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be insert into both DC when A/A ********************" | tee -a ./logs/testcase1.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase1.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase1.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase1.log

#insert data into xdc1
currenttime testcase1.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase1.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase1.log

#juge result of test case 1
currenttime testcase1.log
compare 2>&1 | tee -a ./logs/testcase1.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase1.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase1.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase1.log | tee -a ./logs/Result.log
currenttime testcase1.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 2
#Data can be upsert into both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase2.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase2.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be upsert into both DC when A/A ***********" | tee -a ./logs/testcase2.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase2.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase2.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase2.log

#upsert data into xdc1
currenttime testcase2.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase2.log
sqlci -i ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase2.log

#juge result of test case 2
currenttime testcase2.log
compare 2>&1 | tee -a ./logs/testcase2.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase2.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase2.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase2.log | tee -a ./logs/Result.log
currenttime testcase2.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 3
#Data can be upsert using load into both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase3.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase3.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be upsert using load into both DC when A/A *******" | tee -a ./logs/testcase3.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase3.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase1.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase3.log

#upsert data using load into
currenttime testcase3.log
sh ./scripts/upsert_use_load.sh 2>&1 | tee -a ./logs/testcase3.log
sqlci -i ./sql/upsert_use_load.sql 2>&1 | tee -a ./logs/testcase3.log

#juge result of test case 3
currenttime testcase3.log
compare 2>&1 | tee -a ./logs/testcase3.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number successfully ********************" | tee -a ./logs/testcase3.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase3.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase3.log | tee -a ./logs/Result.log
currenttime testcase3.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 4
#Data can be load into both DC from other table when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase4.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase4.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be load into both DC from other table when A/A ********************" | tee -a ./logs/testcase4.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase4.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase4.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase4.log

#create a no syn table xdc on DC1
currenttime testcase4.log
sqlci -i ./sql/CreateNoSynTable.sql 2>&1 | tee -a ./logs/testcase4.log

#insert data into xdc
currenttime testcase4.log
sh ./scripts/insert_xdc.sh 2>&1 | tee -a ./logs/testcase4.log
sqlci -i ./sql/insert_xdc.sql 2>&1 | tee -a ./logs/testcase4.log

#load data into xdc1 from xdc
currenttime testcase4.log
sqlci -i ./sql/load_from_xdc_to_xdc1.sql 2>&1 | tee -a ./logs/testcase4.log

#juge result of test case 4
currenttime testcase4.log
compare 2>&1 | tee -a ./logs/testcase4.log
if [ $? -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase4.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase4.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase4.log | tee -a ./logs/Result.log
currenttime testcase4.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

#run test case 5
#Data can be updated to both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase5.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase5.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be updated to both DC when A/A ********************" | tee -a ./logs/testcase5.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase5.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase5.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase5.log

#insert data into xdc1
currenttime testcase5.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase5.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase5.log

#update data of xdc1
currenttime testcase5.log
sh ./scripts/update.sh 2>&1 | tee -a ./logs/testcase5.log
sqlci -i ./sql/update.sql 2>&1 | tee -a ./logs/testcase5.log

#juge result of test case 5
currenttime testcase5.log
compare 2>&1 | tee -a ./logs/testcase5.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase5.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase5.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase5.log | tee -a ./logs/Result.log
currenttime testcase5.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 6
#Data can be deleted in both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase6.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase6.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be deleted in both DC when A/A ********************" | tee -a ./logs/testcase6.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase6.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase6.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase6.log

#insert data into xdc1
currenttime testcase6.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase6.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase6.log

#delete data from xdc1
currenttime testcase6.log
sh ./scripts/delete.sh 2>&1 | tee -a ./logs/testcase6.log
sqlci -i ./sql/delete.sql 2>&1 | tee -a ./logs/testcase6.log

#juge result of test case 6
currenttime testcase6.log
compare 2>&1 | tee -a ./logs/testcase6.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase6.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase6.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase6.log | tee -a ./logs/Result.log
currenttime testcase6.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 7
#Data can be deleted with rollback in both DC when A/A
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase7.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase7.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be deleted with rollback in both DC when A/A ********************" | tee -a ./logs/testcase7.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase7.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase7.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase7.log

#insert data into xdc1
currenttime testcase7.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase7.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase7.log

#delete data from xdc1
currenttime testcase7.log
sqlci -i ./sql/delete_with_norollback.sql 2>&1 | tee -a ./logs/testcase7.log

#juge result of test case 7
currenttime testcase7.log
compare 2>&1 | tee -a ./logs/testcase7.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase7.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase7.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase7.log | tee -a ./logs/Result.log
currenttime testcase7.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 8
#Insert data, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase8.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase8.log | tee -a ./logs/Result.log
echo
echo "************************** Insert data, after rollback work,data can't be update. ********************" | tee -a ./logs/testcase8.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase8.log
echo "starting create a syn table named xdc1 in $dc1_ip_1 now!!!!!!!" 2>&1 | tee -a ./logs/testcase8.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase8.log
#pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase8.log
echo "starting create a syn table named xdc1 in $dc2_ip_1 now!!!!!!!" 2>&1 | tee -a ./logs/testcase8.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase8.log

#insert data into xdc1
#the output file is ./logs/insert_rollback.log
#run this command on background
currenttime testcase8.log
echo "starting insert data into a syn table named xdc1 in $dc1_ip_1 now!!!!!!!" 2>&1 | tee -a ./logs/testcase8.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/insert_rollback.sql >> ./logs/testcase8.log
echo "starting select * from a syn table named xdc1  in $dc2_ip_1 now!!!!!!!" 2>&1 | tee -a ./logs/testcase8.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/insert_rollback1.sql | tee -a ./logs/testcase8.log
#pdsh -w $dc2_ip_1 "trafci -s /opt/trafodion/xdc_automatic/sql/insert_rollback.sql" | tee -a ./logs/testcase8.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/insert_rollback_peer.log ./logs/
sleep 15
currenttime testcase8.log
echo "the value of diff two file named insert_rollback.log and insert_rollback_peer.log as follows!!!!" 2>&1 | tee -a ./logs/testcase8.log
rt1=$(diff ./logs/insert_rollback.log ./logs/insert_rollback_peer.log | wc -l)
diff ./logs/insert_rollback.log ./logs/insert_rollback_peer.log 2>&1 | tee -a ./logs/testcase8.log

#juge result of test case 8
currenttime testcase8.log
compare 2>&1 | tee -a ./logs/testcase8.log
if [ $? -eq 1 ] && [ $rt1 -gt 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase8.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase8.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase8.log | tee -a ./logs/Result.log
currenttime testcase8.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 9
#Upsert data, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase9.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase9.log | tee -a ./logs/Result.log
echo
echo "************************** Upsert data, after rollback work,data can't be update. ********************" | tee -a ./logs/testcase9.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase9.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase9.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase9.log

#upsert data into xdc1
#the output file is ./logs/upsert_rollback.log
currenttime testcase9.log
echo "begin to upsert data into $dc1_ip_1 now !!!!!" | tee -a ./logs/testcase9.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/upsert_rollback.sql | tee -a ./logs/testcase9.log
echo "begin to select data from $dc2_ip_1 now !!!!!" | tee -a ./logs/testcase9.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s /opt/trafodion/xdc_automatic/sql/upsert_rollback1.sql | tee -a ./logs/testcase9.log
sleep 15
#sqlci -i ./sql/upsert_rollback.sql | tee -a ./logs/testcase9.log &            #run this command in backgroud
#pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/upsert_rollback.sql" | tee -a ./logs/testcase9.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/upsert_rollback_peer.log ./logs/
rt1=$(diff ./logs/upsert_rollback.log ./logs/upsert_rollback_peer.log | wc -l)
diff ./logs/upsert_rollback.log ./logs/upsert_rollback_peer.log | tee -a ./logs/testcase9.log

#juge result of test case 9
currenttime testcase9.log
compare 2>&1 | tee -a ./logs/testcase9.log
if [ $? -eq 1 ] && [ $rt1 -gt 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase9.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase9.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase9.log | tee -a ./logs/Result.log
currenttime testcase9.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 10
#Upsert using load into data, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase10.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase10.log | tee -a ./logs/Result.log
echo
echo "************************** Upsert using load into data, after rollback work,data can't be update. ********************" | tee -a ./logs/testcase10.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase10.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase10.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase10.log

#upsert data into xdc1
#the output file is ./logs/upsert_useload_rollback.log
currenttime testcase10.log
echo "begin upsert using load into table xdc1 now !!!!!!" | tee -a ./logs/testcase10.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/upsert_useload_rollback.sql | tee -a ./logs/testcase10.log             #run this command in backgroud
echo "select data from $dc2_ip_1 now !!!!!!" | tee -a ./logs/testcase10.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s /opt/trafodion/xdc_automatic/sql/upsert_useload_rollback1.sql | tee -a ./logs/testcase10.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/upsert_useload_rollback_peer.log ./logs/
rt1=$(diff ./logs/upsert_useload_rollback.log ./logs/upsert_useload_rollback_peer.log |wc -l)
diff ./logs/upsert_useload_rollback.log ./logs/upsert_useload_rollback_peer.log | tee -a ./logs/testcase10.log

#juge result of test case 10
currenttime testcase10.log
compare 2>&1 | tee ./logs/testcase10.log
if [ $? -eq 1 ] && [ $rt1 -gt 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase10.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase10.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase10.log | tee -a ./logs/Result.log
currenttime testcase10.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log



#run test case 11
#Transactions are not allowd with load into from other table.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase11.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase11.log | tee -a ./logs/Result.log
echo
echo "************************** Transactions are not allowd with load into from other table. ********************" | tee -a ./logs/testcase11.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase11.log
echo "behin to create a syn table named xdc1 on $dc1_ip_1 !!!!!!!" | tee -a ./logs/testcase11.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase11.log
echo "begin to create a syn table named xdc1 on $dc2_ip_1 !!!!!!!" | tee -a ./logs/testcase11.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase11.log

#create a no syn table xdc on DC1
currenttime testcase11.log
echo "begin to create a non syn table named xdc on dc1 !!!!!!!!" | tee -a ./logs/testcase11.log
sqlci -i ./sql/CreateNoSynTable.sql 2>&1 | tee -a ./logs/testcase11.log

#insert data into xdc
currenttime testcase11.log
echo "insert data into table named xdc !!!!!!!" | tee -a ./logs/testcase11.log
sh ./scripts/insert_xdc.sh 2>&1 | tee -a ./logs/testcase11.log
sqlci -i ./sql/insert_xdc.sql 2>&1 | tee -a ./logs/testcase11.log

#load data into xdc1 from xdc with transaction, the name of log file is load_rollback.log
currenttime testcase11.log
echo "load data from xdc into xdc1, it will failed !!!!!!" | tee -a ./logs/testcase11.log
trafci.sh -h $dc1_ip_1 -u db__root -p traf123 -s ./sql/load_rollback.sql | tee -a ./logs/testcase11.log         #run this command in backgroud
#trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/load_rollback1.sql | tee -a ./logs/testcase11.log

#juge result of test case 11
#compare
#if [ $? -eq 1 ] && 
currenttime testcase11.log
if [ `grep -c "Transactions are not allowd with Bulk load" ./logs/load_rollback.log` -gt '0' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase11.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase11.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase11.log | tee -a ./logs/Result.log
currenttime testcase11.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 12
#Update data, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase12.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase12.log | tee -a ./logs/Result.log
echo
echo "************************** Update data, after rollback work,data can't be update. ********************" | tee -a ./logs/testcase12.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase12.log
echo "begin to create a syn table named xdc1 in DC1 !!!!!!!" | tee -a ./logs/testcase12.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase12.log
echo "begin to create a syn table named xdc1 in DC2 !!!!!!!" | tee -a ./logs/testcase12.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase12.log

#insert data into xdc1
currenttime testcase12.log
echo "begin to insert data into xdc1 !!!!!" | tee -a ./logs/testcase12.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase12.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase12.log

#update data in xdc1
#the output file is ./logs/update_rollback.log
currenttime testcase12.log
echo "begin to update data with rollback in DC1 !!!!!!!" | tee -a ./logs/testcase12.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update_rollback.sql | tee -a ./logs/testcase12.log           #run this command in backgroud
echo "begin to select data from xdc1 in DC2 !!!!!!!" | tee -a ./logs/testcase12.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s /opt/trafodion/xdc_automatic/sql/update_rollback1.sql | tee -a ./logs/testcase12.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/update_rollback_peer.log ./logs/
rt1=$(diff ./logs/update_rollback.log ./logs/update_rollback_peer.log | wc -l)
diff ./logs/update_rollback.log ./logs/update_rollback_peer.log | tee -a ./logs/testcase12.log

#juge result of test case 12
currenttime testcase12.log
compare 2>&1 | tee -a ./logs/testcase12.log
if [ $? -eq 1 ] && [ $rt1 -gt 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase12.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase12.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase12.log | tee -a ./logs/Result.log
currenttime testcase12.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

#run test case 13
#Delete data, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase13.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase13.log | tee -a ./logs/Result.log
echo
echo "************************** Delete data, after rollback work,data can't be update. ********************" | tee -a ./logs/testcase13.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase13.log
echo "begin to create a syn table named xdc1 in DC1 !!!!!!!" | tee -a ./logs/testcase13.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase13.log
echo "begin to create a syn table named xdc1 in DC2 !!!!!!!" | tee -a ./logs/testcase13.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase13.log

#insert data into xdc1
currenttime testcase13.log
echo "insert data into xdc1 !!!!!!" | tee -a ./logs/testcase13.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase13.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase13.log

#delete data from xdc1
#the output file is ./logs/delete_rollback.log
currenttime testcase13.log
echo "begin to delete data from xdc1 with rollback in DC1 !!!!!" | tee -a ./logs/testcase13.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete_rollback.sql | tee -a ./logs/testcase13.log       #run this command in backgroud
echo "begin to select data from xdc1 !!!!!!" | tee -a ./logs/testcase13.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s /opt/trafodion/xdc_automatic/sql/delete_rollback1.sql | tee -a ./logs/testcase13.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/delete_rollback_peer.log ./logs/
rt1=$(diff ./logs/delete_rollback.log ./logs/delete_rollback_peer.log | wc -l)
diff ./logs/delete_rollback.log ./logs/delete_rollback_peer.log | tee -a ./logs/testcase13.log

#juge result of test case 13
currenttime testcase13.log
compare 2>&1 | tee -a ./logs/testcase13.log
if [ $? -eq 1 ] && [ $rt1 -gt 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase13.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase13.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase13.log | tee -a ./logs/Result.log
currenttime testcase13.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 14
#Delete data with rollback, after rollback work,data can't be update.
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase14.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase14.log | tee -a ./logs/Result.log
echo
echo "********* Delete data with no rollback, after rollback work,data can't be update. ***" | tee -a ./logs/testcase14.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase14.log
echo "begin to create table at $dc1_ip_1 now !!!!!" | tee -a ./logs/testcase14.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase14.log
echo "begin to create a table at $dc2_ip_1 now !!!!!" | tee -a ./logs/testcase14.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase14.log

#insert data into xdc1
currenttime testcase14.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase14.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase14.log

#delete data with no rollback from xdc1
#the output file is ./logs/delete_withno_rollback.log
currenttime testcase14.log
echo "delete data from xdc1 with no rollback now !!!!!!" | tee -a ./logs/testcase14.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete_withno_rollback.sql | tee -a ./logs/testcase14.log      #run this command in backgroud
echo "select data from xdc1 in $dc2_ip_1 now !!!!!!" | tee -a ./logs/testcase14.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s /opt/trafodion/xdc_automatic/sql/delete_withno_rollback1.sql | tee -a ./logs/testcase14.log
#scp trafodion@$dc2_ip_1:/opt/trafodion/xdc_automatic/logs/delete_withno_rollback_peer.log ./logs/
rt1=$(diff ./logs/delete_withno_rollback.log ./logs/delete_withno_rollback_peer.log | wc -l)
diff ./logs/delete_withno_rollback.log ./logs/delete_withno_rollback_peer.log | tee -a ./logs/testcase14.log

#juge result of test case 14
currenttime testcase14.log
compare 2>&1 | tee -a ./logs/testcase14.log
if [ $? -eq 1 ] && [ `grep -c "The transaction mode at run time" ./logs/testcase14.log` -gt '0' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase14.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase14.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase14.log | tee -a ./logs/Result.log
currenttime testcase14.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 15
#Create a table which one column with default value
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase15.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase15.log | tee -a ./logs/Result.log
echo
echo "************************** Create a table which one column with default value *********" | tee -a ./logs/testcase15.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 which one column with default value on both DC
currenttime testcase15.log
sqlci -i ./sql/CreateTableWithDefault.sql 2>&1 | tee -a ./logs/testcase15.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateTableWithDefault.sql" | tee -a ./logs/testcase15.log

#insert data into xdc1 which one column is default value
currenttime testcase15.log
sh ./scripts/insert_default.sh 2>&1 | tee -a ./logs/testcase15.log
sqlci -i ./sql/insert_default.sql 2>&1 | tee -a ./logs/testcase15.log

#select * from xdc1
currenttime testcase15.log
sh ./scripts/select.sh 2>&1 | tee -a ./logs/testcase15.log
sqlci -i ./sql/select.sql 2>&1 | tee -a ./logs/testcase15.log

#juge result of test case 15
currenttime testcase15.log
if [ `grep -c "jianhua" ./logs/testcase15.log` -gt '100' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase15.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase15.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase15.log | tee -a ./logs/Result.log
currenttime testcase15.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 16
#Data replication failed if violation of primary key
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase16.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase16.log | tee -a ./logs/Result.log
echo
echo "************************** Data replication failed if violation of primary key *********" | tee -a ./logs/testcase16.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 on DC1 and create a no syn table named XDC1 on DC2
currenttime testcase16.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase16.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable.sql" | tee -a ./logs/testcase16.log

#insert data into xdc1
currenttime testcase16.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase16.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase16.log

#insert same data into xdc1 again, it will failed because of primary key constraint
currenttime testcase16.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase16.log

#juge result of test case 16
currenttime testcase16.log
compare 2>&1 | tee -a ./logs/testcase16.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase16.log` -ge '100' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase16.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase16.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase16.log | tee -a ./logs/Result.log
currenttime testcase16.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 17
#Data replication failed if the passive DC2 violation of primary key
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase17.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase17.log | tee -a ./logs/Result.log
echo
echo "************************** Data replication failed if the passive DC2 violation of primary key *********" | tee -a ./logs/testcase17.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 on DC1 and create a no syn table named XDC1 on DC2
currenttime testcase17.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase17.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable.sql" | tee -a ./logs/testcase17.log

#insert same data into xdc1 again in DC2
currenttime testcase17.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert.sh" | tee -a ./logs/testcase17.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql" | tee -a ./logs/testcase17.log

#insert data into xdc1 in DC1, it will failed because of primary key constraint
currenttime testcase17.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase17.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase17.log

#juge result of test case 17
currenttime testcase17.log
compare 2>&1 | tee -a ./logs/testcase17.log
if [ $? -eq 0 ] && [ `grep -c "ERROR" ./logs/testcase17.log` -ge '100' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase17.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase17.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase17.log | tee -a ./logs/Result.log
currenttime testcase17.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

#run test case 18
#Data replication failed if violation of foreign key constraint
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase18.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase18.log | tee -a ./logs/Result.log
echo
echo "************************** Data replication failed if violation of foreign key constraint ********************" 2>&1 | tee -a ./logs/testcase18.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a table name xdc_fk as a foreign table
currenttime testcase18.log
sqlci -i ./sql/CreateFKTable.sql 2>&1 | tee -a ./logs/testcase18.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateFKTable.sql" | tee -a ./logs/testcase18.log

#create a syn table named xdc2 which contain a foreign key in DC1, create a no syn one in DC2
currenttime testcase18.log
sqlci -i ./sql/CreateTableWithFK.sql 2>&1 | tee ./logs/testcase18.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTableWithFK.sql" | tee -a ./logs/testcase18.log

#insert data into xdc_fk
currenttime testcase18.log
sh ./scripts/insert_fk.sh 2>&1 | tee -a ./logs/testcase18.log
sqlci -i ./sql/insert_fk.sql 2>&1 | tee -a ./logs/testcase18.log
#pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert_fk.sh" | tee -a ./logs/testcase18.log
#pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert_fk.sql" | tee -a ./logs/testcase18.log

#insert data into xdc2 in DC1
currenttime testcase18.log
sh ./scripts/insert_xdc2.sh 2>&1 | tee -a ./logs/testcase18.log
sqlci -i ./sql/insert_xdc2.sql 2>&1 | tee -a ./logs/testcase18.log

#insert data into xdc2 again in DC1, it will failed
currenttime testcase18.log
sqlci -i ./sql/insert_xdc2.sql 2>&1 | tee -a ./logs/testcase18.log

#drop table xdc2 and xdc_fk
currenttime testcase18.log
sqlci -i ./sql/drop_xdc2_xdc_fk.sql 2>&1 | tee -a ./logs/testcase18.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/sql/drop_xdc2_xdc_fk.sql" 2>&1 | tee -a ./logs/testcase18.log

#juge result of test case 18
currenttime testcase18.log
if [ `grep -c "ERROR" ./logs/testcase18.log` -ge '300' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase18.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase18.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase18 | tee -a ./logs/Result.log
currenttime testcase18.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 19
#Data replication failed if violation of check key constraint
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase19.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase19.log | tee -a ./logs/Result.log
echo
echo "******************* Data replication failed if violation of check key constraint ***********" 2>&1 | tee -a ./logs/testcase19.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a table named xdc3 which contain checking constraint
currenttime testcase19.log
sqlci -i ./sql/CreateTableWithCK.sql 2>&1 | tee ./logs/testcase19.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateTableWithCK.sql" | tee -a ./logs/testcase19.log

#insert data into xdc_fk
currenttime testcase19.log
sh ./scripts/insert_xdc3.sh 2>&1 | tee -a ./logs/testcase19.log
sqlci -i ./sql/insert_xdc3.sql 2>&1 | tee -a ./logs/testcase19.log

#drop table xdc3
currenttime testcase19.log
sqlci -i ./sql/drop_xdc3.sql 2>&1 | tee -a ./logs/testcase19.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/drop_xdc3.sql" | tee -a ./logs/testcase19.log

#juge result of test case 19
currenttime testcase19.log
if [ `grep -c "ERROR" ./logs/testcase19.log` -ge '10' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" 2>&1 | tee -a ./logs/testcase19.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" 2>&1 | tee -a ./logs/testcase19.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" 2>&1 | tee -a ./logs/testcase19.log | tee -a ./logs/Result.log
currenttime testcase19.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 20
#Synchronous table names are case sensitive("xDC_test",xdc_test)
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase20.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase20.log | tee -a ./logs/Result.log
echo
echo "************************** Synchronous table names are case sensitive(xDC_test,xdc_test) ********************" | tee -a ./logs/testcase20.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table named xDC_test on DC1 and create anthor syn table named xdc_test on DC2
currenttime testcase20.log
sqlci -i ./sql/CreateSynTable_xDC_test.sql 2>&1 | tee -a ./logs/testcase20.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc_test.sql" | tee -a ./logs/testcase20.log

#insert data into xDC_test, it will returned error of TableNotFoundException
#sh ./scripts/insert_xDC_test.sh 2>&1 | tee -a ./logs/testcase20.log
currenttime testcase20.log
sqlci -i ./sql/insert_xDC_test.sql 2>&1 | tee -a ./logs/testcase20.log

#juge result of test case 20
currenttime testcase20.log
if [ `grep -c "TableNotFoundException" ./logs/testcase20.log` -ge '1' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase20.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase20.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase20.log | tee -a ./logs/Result.log
currenttime testcase20.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 21
#Synchronous table names are case sensitive("xDC_test","xDC_TEST")
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase21.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase21.log | tee -a ./logs/Result.log
echo
echo "************************** Synchronous table names are case sensitive(xDC_test,xDC_TEST) *****" | tee -a ./logs/testcase21.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table named "xDC_test" on DC1 and create anthor syn table named "xDC_TEST" on DC2
currenttime testcase21.log
sqlci -i ./sql/CreateSynTable_xDC_test.sql 2>&1 | tee -a ./logs/testcase21.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xDC_TEST.sql" | tee -a ./logs/testcase21.log

#insert data into xDC_test, it will returned error of TableNotFoundException
#sh ./scripts/insert_xDC_test.sh 2>&1 | tee -a ./logs/testcase21.log
currenttime testcase21.log
sqlci -i ./sql/insert_xDC_test.sql 2>&1 | tee -a ./logs/testcase21.log

#juge result of test case 21
currenttime testcase21.log
if [ `grep -c "TableNotFoundException" ./logs/testcase20.log` -ge '1' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase21.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase21.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase21.log | tee -a ./logs/Result.log
currenttime testcase21.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 22
#Data can be inserted into both DC which table name is "xDC_test"
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase22.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase22.log | tee -a ./logs/Result.log
echo
echo "************************** Data can be inserted into both DC which table name is xDC_test ********************" | tee -a ./logs/testcase22.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table named "xDC_test" on DC1 and DC2
currenttime testcase22.log
sqlci -i ./sql/CreateSynTable_xDC_test.sql 2>&1 | tee -a ./logs/testcase22.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xDC_test.sql" | tee -a ./logs/testcase22.log

#insert data into xDC_test, data will be shown in DC1 and DC2
#sh ./scripts/insert_xDC_test.sh 2>&1 | tee -a ./logs/testcase22.log
currenttime testcase22.log
sqlci -i ./sql/insert_xDC_test.sql 2>&1 | tee -a ./logs/testcase22.log

#insert data in DC2
#pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert_xDC_test.sh" | tee -a ./logs/testcase22.log
currenttime testcase22.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert_xDC_test.sql" | tee -a ./logs/testcase22.log

#juge result of test case 22
currenttime testcase22.log
compare_xDC_test 2>&1 | tee -a ./logs/testcase22.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase22.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase22.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase22.log | tee -a ./logs/Result.log
currenttime testcase22.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 23
#Data can be inserted into both DC which table name is "XDC_TEST" and xdc_test
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase23.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase23.log | tee -a ./logs/Result.log
echo
echo "******** Data can be inserted into both DC which table name is XDC_TEST and xdc_test ********" | tee -a ./logs/testcase23.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table named "XDC_TEST" on DC1 and  a table named xdc_test in DC2
currenttime testcase23.log
sqlci -i ./sql/CreateSynTable_XDC_TEST.sql 2>&1 | tee -a ./logs/testcase23.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc_test.sql" | tee -a ./logs/testcase23.log

#insert data into XDC_TEST, data will be shown in DC1 and DC2
currenttime testcase23.log
sh ./scripts/insert_XDC_TEST.sh 2>&1 | tee -a ./logs/testcase23.log
sqlci -i ./sql/insert_XDC_TEST.sql 2>&1 | tee -a ./logs/testcase23.log

#insert data in DC2
currenttime testcase23.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert_xdc_test.sh" | tee -a ./logs/testcase23.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert_xdc_test.sql" | tee -a ./logs/testcase23.log

#select * from xdc_test in botn DC and compare the result
currenttime testcase23.log
echo "select data from $dc1_ip_1 now !!!!!" | tee -a ./logs/testcase23.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/compare_XDC_TEST.sql 2>&1 | tee -a ./logs/testcase23.log
echo "select data from $dc2_ip_1 now !!!!!" | tee -a ./logs/testcase23.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/compare_xdc_test.sql 2>&1 | tee -a ./logs/testcase23.log
rt1=$(diff ./logs/compare_current_xdc_test.log ./logs/compare_peer_xdc_test.log | wc -l)
diff ./logs/compare_current_xdc_test.log ./logs/compare_peer_xdc_test.log 2>&1 | tee -a ./logs/testcase23.log
echo
echo $rt1
echo

#juge result of test case 23
currenttime testcase23.log
if [ $rt1 -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase23.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase23.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase23.log | tee -a ./logs/Result.log
currenttime testcase23.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 24
#add a column in two DC's tables while there are some data in the synchronization table
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase24.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase24.log | tee -a ./logs/Result.log
echo
echo "************************** Add a column in two DC which contain some data *************" 2>&1 | tee -a ./logs/testcase24.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 on both DC
currenttime testcase24.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase24.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase24.log

#insert data into XDC1
currenttime testcase24.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase24.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase24.log

#add a column age in both DC`s table
currenttime testcase24.log
sqlci -i ./sql/add_column.sql 2>&1 | tee -a ./logs/testcase24.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/add_column.sql" | tee -a ./logs/testcase24.log

#insert data into XDC1
currenttime testcase24.log
sh ./scripts/insert_age.sh 2>&1 | tee -a ./logs/testcase24.log
sqlci -i ./sql/insert_age.sql 2>&1 | tee -a ./logs/testcase24.log

#juge result of test case 24
currenttime testcase24.log
compare 2>&1 | tee -a ./logs/testcase24.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase24.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase24.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase24.log | tee -a ./logs/Result.log
currenttime testcase24.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 25
#Drop a column in two DC's tables while there are some data in the synchronization table
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase25.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase25.log | tee -a ./logs/Result.log
echo
echo "************************** Drop a column in two DC which there are some data ***********" 2>&1 | tee -a ./logs/testcase25.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 on both DC
currenttime testcase25.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase25.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase25.log

#insert data into XDC1
currenttime testcase25.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase25.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase25.log

#delete a column salary in both DC`s table
currenttime testcase25.log
sqlci -i ./sql/delete_column.sql 2>&1 | tee -a ./logs/testcase25.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_column.sql" | tee -a ./logs/testcase25.log

#juge result of test case 25
currenttime testcase25.log
compare 2>&1 | tee -a ./logs/testcase25.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase25.log` -gt '0' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase25.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase25.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase25.log | tee -a ./logs/Result.log
currenttime testcase25.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 26
#Change the data type of the synchronization table
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase26.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase26.log | tee -a ./logs/Result.log
echo
echo "************************** Change the data type of the synchronization table **********" 2>&1 | tee -a ./logs/testcase26.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table naed XDC1 on both DC
currenttime testcase26.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase26.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase26.log

#insert data into XDC1
#sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase26.log
#sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase26.log

#Change the data type of the synchronization table
currenttime testcase26.log
sqlci -i ./sql/change_type.sql 2>&1 | tee -a ./logs/testcase26.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/change_type.sql" | tee -a ./logs/testcase26.log

#upsert data into xdc1
currenttime testcase26.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase26.log
sqlci -i ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase26.log

#juge result of test case 26
currenttime testcase26.log
compare 2>&1 | tee -a ./logs/testcase26.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase26.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase26.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase26.log | tee -a ./logs/Result.log
currenttime testcase26.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log



#run test case 27
#[Recovery]"xdc -set -id 31 -status sdn" will disable one way replication and become sup/sdn with xdc -push
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase27.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase27.log | tee -a ./logs/Result.log
echo
echo "*** xdc set it own staus sdn will disable one way replication and become sup/sdn with xdc -push **" | tee -a ./logs/testcase27.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase27.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase27.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase27.log

#xdc -set -id 31 -status sdn, xdc -push
#when 31`s status is sdn, insert data into 31, it will syn, otherwise insert data into 57 it will not syn
currenttime testcase27.log
xdc -set -id 31 -status sdn 2>&1 | tee -a ./logs/testcase27.log
xdc -push 2>&1 | tee -a ./logs/testcase27.log

#insert data into xdc1 in 31
currenttime testcase27.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase27.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase27.log

#compare the data between DC1 and DC2, it will syn, return value is 1
currenttime testcase27.log
compare 2>&1 | tee -a ./logs/testcase27.log
rt1=$?

#delete data from xdc1 in 31
currenttime testcase27.log
sh ./scripts/delete_all.sh 2>&1 | tee -a ./logs/testcase27.log
sqlci -i ./sql/delete_all.sql 2>&1 | tee -a ./logs/testcase27.log

#insert data into 57
currenttime testcase27.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase27.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase27.log

#compare the data between DC1 and DC2 it will not syn, the value of returned is 0
currenttime testcase27.log
compare 2>&1 | tee -a ./logs/testcase27.log
rt2=$?

#delete data from xdc1 in $dc2_ip_1
currenttime testcase27.log
echo "exit" >> ./sql/delete_all.sql 2>&1 | tee -a ./logs/testcase27.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/delete_all.sql 2>&1 | tee -a ./logs/testcase27.log

#xdc -set -id 31 -status sup, xdc -push
currenttime testcase27.log
xdc -set -id 31 -status sup 2>&1 | tee -a ./logs/testcase27.log
xdc -push 2>&1 | tee -a ./logs/testcase27.log

#juge result of test case 27
currenttime testcase27.log
compare 2>&1 | tee -a ./logs/testcase27.log
if [ $rt1 -eq 1 ] && [ $rt2 -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase27.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase27.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase27.log | tee -a ./logs/Result.log
currenttime testcase27.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 28
#[Recovery]"xdc -set -id 31 -status sup",data replication successfully and become sup/sup with xdc -push
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase28.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase28.log | tee -a ./logs/Result.log
echo
echo "*** xdc set it own staus sup, data will replication and become sup/sup with xdc -push **" | tee -a ./logs/testcase28.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase28.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase28.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase28.log

#xdc -set -id 31 -status sdn, xdc -push
#when 31`s status is sdn, insert data into 31, it will syn, otherwise insert data into 57 it will not syn
currenttime testcase28.log
xdc -set -id 31 -status sdn | tee -a ./logs/testcase28.log
xdc -push | tee -a ./logs/testcase28.log

#insert data into 57
currenttime testcase28.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert.sh" | tee -a ./logs/testcase28.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql"| tee -a ./logs/testcase28.log

#compare the data between DC1 and DC2 it will not syn, the value of returned is 0
currenttime testcase28.log
compare 2>&1 | tee -a ./logs/testcase28.log
rt1=$?

#delete data from 57
currenttime testcase28.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/delete_all.sh" | tee -a ./logs/testcase28.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_all.sql"| tee -a ./logs/testcase28.log

#xdc -set -id 31 -status sup, xdc -push
#when 31`s status is sup, insert data into 31, it will syn, otherwise insert data into 57 it also will syn
currenttime testcase28.log
xdc -set -id 31 -status sup | tee -a ./logs/testcase28.log
xdc -push | tee -a ./logs/testcase28.log

#insert data into 57
currenttime testcase28.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert.sh" | tee -a ./logs/testcase28.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql"| tee -a ./logs/testcase28.log

#compare the data between DC1 and DC2 it will syn, the value of returned is 1
currenttime testcase28.log
compare 2>&1 | tee -a ./logs/testcase28.log
rt2=$?

#juge result of test case 28
currenttime testcase28.log
compare 2>&1 | tee -a ./logs/testcase28.log
if [ $rt1 -eq 0 ] && [ $rt2 -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase28.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase28.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase28.log | tee -a ./logs/Result.log
currenttime testcase28.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 29
#[Recovery]"xdc -set -id 57 -status sdn" will disable one way replication and become sup/sdn with xdc -push
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase29.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase29.log | tee -a ./logs/Result.log
echo
echo "*** xdc set peer DC staus sdn will disable one way replication and become sup/sdn with xdc -push **" | tee -a ./logs/testcase29.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase29.log
echo "create table name xdc1 in both DC now !!!!" | tee -a ./logs/testcase29.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase29.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase29.log

#xdc -set -id 57 -status sdn, xdc -push
#when 57`s status is sdn, insert data into 31, it will not syn, otherwise insert data into 57 it will syn
currenttime testcase29.log
echo "begin to execute xdc -set -id 57 -status sdn now !!!!!" | tee -a ./logs/testcase29.log
xdc -set -id 57 -status sdn | tee -a ./logs/Result.log
xdc -push | tee -a ./logs/Result.log

#insert data into xdc1 in 31
currenttime testcase29.log
echo "insert data into xdc1 in 31, it will not syn !!!!!" | tee -a ./logs/testcase29.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase29.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase29.log

#compare the data between DC1 and DC2, it will not syn, return value is 0
currenttime testcase29.log
compare 2>&1 | tee -a ./logs/testcase29.log
rt1=$?

#delete data from xdc1 in 31
currenttime testcase29.log
sh ./scripts/delete_all.sh 2>&1 | tee -a ./logs/testcase29.log
sqlci -i ./sql/delete_all.sql 2>&1 | tee -a ./logs/testcase29.log

#insert data into 57
currenttime testcase29.log
echo "insert data into 57 , it will syn !!!!!!" | tee -a ./logs/testcase29.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase29.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase29.log

#compare the data between DC1 and DC2 it will syn, the value of returned is 1
currenttime testcase29.log
compare 2>&1 | tee -a ./logs/testcase29.log
rt2=$?

#xdc -set -id 57 -status sup
currenttime testcase29.log
xdc -set -id 57 -status sup | tee -a ./logs/testcase29.log
xdc -push | tee -a ./logs/testcase29.log

#juge result of test case 29
currenttime testcase29.log
compare 2>&1 | tee -a ./logs/testcase29.log
if [ $rt1 -eq 0 ] && [ $rt2 -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase29.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase29.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase29.log | tee -a ./logs/Result.log
currenttime testcase29.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log



#run test case 30
#[Recovery]"xdc_peer_down" will disable one way replication and become sup/sdn
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase30.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase30.log | tee -a ./logs/Result.log
echo
echo "*** xdc_peer_down will disable one way replication and become sup/sdn **" | tee -a ./logs/testcase30.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase30.log
echo "create a syn table named xdc1 in both DC now !!!!!" | tee -a ./logs/testcase30.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase30.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase30.log

#xdc_peer_down -p 57
#when 57`s status is sdn, insert data into 31, it will successfully, but will not syn 
#otherwise insert data into 57 it will return error
currenttime testcase30.log
echo " execute xdc_peer_down -p 57 now !!!!!!" | tee -a ./logs/testcase30.log

#insert data into xdc1 in 31
currenttime testcase30.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase30.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase30.log

#compare the data between DC1 and DC2, it will not syn, return value is 0
currenttime testcase30.log
compare 2>&1 | tee -a ./logs/testcase30.log
rt1=$?

#inset data into xdc1 in DC2, it will return error
currenttime testcase30.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/upsert.sh" | tee -a ./logs/testcase30.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/upsert.sql" | tee -a ./logs/testcase30.log

#execute xdc_peer_up -p 57, data will syn in DC1 and DC2
currenttime testcase30.log
echo "execute xdc_peer_up -p 57 now !!!!!" | tee -a ./logs/testcase30.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase30.log
sleep 30

#compare the data between DC1 and DC2 it will syn, the value of returned is 1
currenttime testcase30.log
compare 2>&1 | tee -a ./logs/testcase30.log
rt2=$?

#juge result of test case 30
currenttime testcase30.log
echo
echo $rt1
echo $rt2
echo
if [ $rt1 -eq 0 ] && [ $rt2 -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase30.log` -gt '0' ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase30.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase30.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase30.log | tee -a ./logs/Result.log
currenttime testcase30.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 31
#[Recovery]"xdc_peer_down" will not impact non-synchronous table
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase31.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase31.log | tee -a ./logs/Result.log
echo
echo "*** xdc_peer_down will not impact non-synchronous table **" | tee -a ./logs/testcase31.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
#echo "begin to create a table named xdc1 on both DC !!!!!"
#sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase31.log
#pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase31.log

#create a no syn table named xdc on DC1 and DC2
currenttime testcase31.log
echo "begin to create a non syn table named xdc on both DC now !!!!!" | tee -a ./logs/testcase31.log
sqlci -i ./sql/CreateNoSynTable_xdc.sql 2>&1 | tee -a ./logs/testcase31.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable_xdc.sql" | tee -a ./logs/testcase31.log

#xdc_peer_down -p 57
currenttime testcase31.log
echo "execute xdc_peer_down -p 57 now !!!!!" | tee -a ./logs/testcase31.log
xdc_peer_down -p 57 2>&1 | tee -a ./logs/testcase31.log

#insert data into xdc in DC1
currenttime testcase31.log
echo "insert data into a non syn table named xdc now !!!!!" | tee -a ./logs/testcase31.log
sh /opt/trafodion/xdc_automatic/scripts/DML_ON_XDC.sh | tee -a ./logs/testcase31.log
sqlci -i /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql | tee -a ./logs/testcase31.bak.log
rt1=$(grep -c "ERROR" ./logs/testcase31.bak.log)

#inset data into xdc in DC2, it will execute seccessfully
currenttime testcase31.log
echo "insert data into a non syn table named xdc in $dc2_ip_1 now !!!!" | tee -a ./logs/testcase31.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/DML_ON_XDC.sh" | tee -a ./logs/testcase31.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql" | tee -a ./logs/testcase31.bak1.log
rt2=$(grep -c "ERROR" ./logs/testcase31.bak1.log)

#execute xdc_peer_up -p 57
currenttime testcase31.log
echo "execute xdc_peer_up -p 57 now !!!!!" | tee -a ./logs/testcase31.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase31.log
sleep 30

#juge result of test case 31
currenttime testcase31.log
if [ $rt1 -gt 0 ] && [ $rt2 -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase31.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase31.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase31.log | tee -a ./logs/Result.log
currenttime testcase31.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 32
#[Recovery]"xdc_peer_up" will enable one way replication and become sup/sup
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase32.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase32.log | tee -a ./logs/Result.log
echo
echo "*** xdc_peer_up will execute successfully whne DC1 coantain a syn table and DC2 contain a no syn table**" | tee -a ./logs/testcase32.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on DC1 and create a non syn table named xdc1 on DC2
currenttime testcase32.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase32.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable.sql" | tee -a ./logs/testcase32.log

#xdc_peer_down -p 57, data can be inserted in 31, but not allowed in 57
currenttime testcase32.log
xdc_peer_down -p 57 | tee -a ./logs/testcase32.log

#insert data into 31
currenttime testcase32.log
sh /opt/trafodion/xdc_automatic/scripts/insert.sh | tee -a ./logs/testcase32.log
sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql | tee -a ./logs/testcase32.log

#compare the data between DC1 and DC2 it will not syn, the value of returned is 0
currenttime testcase32.log
compare 2>&1 | tee -a ./logs/testcase32.log
rt1=$?

#execute xdc_peer_up -p 57, data will syn in both DC
currenttime testcase32.log
xdc_peer_up -p 57 | tee -a ./logs/testcase32.log
sleep 30

#compare the data between DC1 and DC2 it will syn, the value of returned is 1
currenttime testcase32.log
compare 2>&1 | tee -a ./logs/testcase32.log
rt2=$?

#juge result of test case 32
currenttime testcase32.log
compare 2>&1 | tee -a ./logs/testcase32.log
if [ $rt1 -eq 0 ] && [ $rt2 -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase32.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase32.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase32.log | tee -a ./logs/Result.log
currenttime testcase32.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 33
#mutition replay twice, only one data
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase33.log
echo "************************** Test Case $testcase_number *********************************" 2>&1 | tee ./logs/testcase33.log | tee -a ./logs/Result.log
echo
echo "*** execute xdc_peer_up twice, there is one data replication to peer DC**" 2>&1 | tee -a ./logs/testcase33.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on DC1 and create a non syn table named xdc1 on DC2
currenttime testcase33.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase33.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable.sql" 2>&1 | tee -a ./logs/testcase33.log

#xdc_peer_down -p 57, data can be inserted in 31, but not allowed in 57
currenttime testcase33.log
xdc_peer_down -p 57 2>&1 | tee -a ./logs/testcase33.log

#insert data into 31
currenttime testcase33.log
sh /opt/trafodion/xdc_automatic/scripts/insert.sh 2>&1 | tee -a ./logs/testcase33.log
sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql 2>&1 | tee -a ./logs/testcase33.log

#compare the data between DC1 and DC2 it will not syn, the value of returned is 0
currenttime testcase33.log
compare 2>&1 | tee -a ./logs/testcase33.log
rt1=$?

#execute xdc_peer_up -p 57, data will syn in both DC
currenttime testcase33.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase33.log

#select * from xdc1 in DC2
currenttime testcase33.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/select.sh" 2>&1 | tee -a ./logs/testcase33.log
pdsh -w $dc2_ip_1 "sqlci -i  /opt/trafodion/xdc_automatic/sql/select.sql" 2>&1 | tee -a ./logs/testcase33.bak.log

#execute xdc_peer_up -p 57, data will syn in both DC
currenttime testcase33.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase33.log

#select * from xdc1 in DC2
currenttime testcase33.log
pdsh -w $dc2_ip_1 "sqlci -i  /opt/trafodion/xdc_automatic/sql/select.sql" 2>&1 | tee -a ./logs/testcase33.bak1.log

#compare the data between DC1 and DC2 it will syn, the value of returned is 0
rt2=$(diff ./logs/testcase33.bak.log ./logs/testcase33.bak1.log | wc -l)

#juge result of test case 33
currenttime testcase33.log
if [ $rt1 -eq 0 ] && [ $rt2 -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase33.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase33.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase33.log | tee -a ./logs/Result.log
currenttime testcase33.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 34
#attributes no replication
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase34.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase34.log | tee -a ./logs/Result.log
echo
echo "*** attributes no replication **" | tee -a ./logs/testcase34.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase34.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase34.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase34.log

#xdc_peer_down -p 57
currenttime testcase34.log
xdc_peer_down -p 57 2>&1 | tee -a ./logs/testcase34.log

#alter table xdc1 attribute no replication
currenttime testcase34.log
sqlci -i ./sql/set_no_replication_xdc1.sql 2>&1 | tee -a ./logs/testcase34.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/set_no_replication_xdc1.sql" | tee -a ./logs/testcase34.log

#insert data into xdc in DC1, it will failed
currenttime testcase34.log
sh /opt/trafodion/xdc_automatic/scripts/insert.sh | tee -a ./logs/testcase34.log
sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql | tee -a ./logs/testcase34.bak.log
rt1=$(grep -c "ERROR" ./logs/testcase34.bak.log)

#inset data into xdc in DC2, it will execute seccessfully
currenttime testcase34.log
pdsh -w $dc2_ip_1 "sh /opt/trafodion/xdc_automatic/scripts/insert.sh" | tee -a ./logs/testcase34.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/insert.sql" | tee -a ./logs/testcase34.bak1.log
rt2=$(grep -c "ERROR" ./logs/testcase34.bak1.log)

#execute xdc_peer_up -p 57
currenttime testcase34.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase34.log
sleep 30

#juge result of test case 34
currenttime testcase34.log
compare 2>&1 | tee -a ./logs/testcase34.log
if [ $? -eq 0 ] && [ $rt1 -gt 0 ] && [ $rt2 -eq 0 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase34.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase34.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase34.log | tee -a ./logs/Result.log
currenttime testcase34.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log



#run test case 35
#attributes synchronous replication
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase35.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase35.log | tee -a ./logs/Result.log
echo
echo "*** attributes synchronous replication **" | tee -a ./logs/testcase35.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a non syn table xdc1 on both DC
currenttime testcase35.log
sqlci -i ./sql/CreateNoSynTable.sql 2>&1 | tee -a ./logs/testcase35.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateNoSynTable_xdc.sql" | tee -a ./logs/testcase35.log

#xdc_peer_down -p 57
currenttime testcase35.log
xdc_peer_down -p 57 2>&1 | tee -a ./logs/testcase35.log

#alter table xdc1 attribute synchronous replication
currenttime testcase35.log
sqlci -i ./sql/set_replication_xdc.sql 2>&1 | tee -a ./logs/testcase35.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/set_replication_xdc.sql" | tee -a ./logs/testcase35.log

#execute xdc_peer_up -p 57
currenttime testcase35.log
xdc_peer_up -p 57 2>&1 | tee -a ./logs/testcase35.log
sleep 30

#insert data into xdc in DC1, it will failed
currenttime testcase35.log
sh /opt/trafodion/xdc_automatic/scripts/insert_xdc.sh | tee -a ./logs/testcase35.log
sqlci -i /opt/trafodion/xdc_automatic/sql/insert_xdc.sql | tee -a ./logs/testcase35.log

#juge result of test case 35
currenttime testcase35.log
compareXDC 2>&1 | tee -a ./logs/testcase35.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase35.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase35.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase35.log | tee -a ./logs/Result.log
currenttime testcase35.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 36
#tc qdisc add dev eth0 root netem delay 1000ms 100ms
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase36.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase36.log | tee -a ./logs/Result.log
echo
echo "************ tc qdisc add dev eth0 root netem delay 1000ms 100ms ******************" | tee -a ./logs/testcase36.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase36.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase36.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase36.log

#tc qdisc add dev eth0 root netem delay 1000ms 100ms
#only in root, we can execuete the command of TC
currenttime testcase36.log
echo "execute command of TC to delay  of package now !!!!!!" | tee -a ./logs/testcase36.log
sleep 10
su - root << EOF
linux
sleep 10 
tc qdisc add dev eth0 root netem delay 100ms 100ms
EOF
sleep 10

#insert data into xdc1
currenttime testcase36.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase36.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase36.log

#tc qdisc del dev eth0 root netem delay 1000ms 100ms
currenttime testcase36.log
echo "execute commadn of TC to cancel the delay of Pakacge now !!!!!" | tee -a ./logs/testcase36.log
sleep 10
su - root << EOF
linux
sleep 10
tc qdisc del dev eth0 root netem delay 100ms 100ms
EOF
sleep 10

#juge result of test case 36
currenttime testcase36.log
compare 2>&1 | tee -a ./logs/testcase36.log
if [ $? -eq 1 ]; then
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase36.log | tee -a ./logs/Result.log
let success_number=success_number+1
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase36.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase36.log | tee -a ./logs/Result.log
currenttime testcase36.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 37
#tc qdisc add dev eth0 root netem loss 30%
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase37.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase37.log | tee -a ./logs/Result.log
echo
echo "************ tc qdisc add dev eth0 root netem loss 30% ******************" | tee -a ./logs/testcase37.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase37.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase37.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase37.log

#tc qdisc add dev eth0 root netem loss 30%
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc add dev eth0 root netem loss 10%
EOF
sleep 5

#insert data into xdc1
currenttime testcase37.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase37.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase37.log

#tc qdisc del dev eth0 root netem loss 30%
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc del dev eth0 root netem loss 10%
EOF
sleep 5

#juge result of test case 37
currenttime testcase37.log
compare 2>&1 | tee -a ./logs/testcase37.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase37.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase37.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase37.log | tee -a ./logs/Result.log
currenttime testcase37.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 38
#tc qdisc add dev eth0 root netem duplicate 10%
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase38.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase38.log | tee -a ./logs/Result.log
echo
echo "************ tc qdisc add dev eth0 root netem duplicate 10% ******************" | tee -a ./logs/testcase38.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase38.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase38.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase38.log

#tc qdisc add dev eth0 root netem duplicate 10%
currenttime testcase38.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc add dev eth0 root netem duplicate 10%
EOF
sleep 5

#insert data into xdc1
currenttime testcase38.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase38.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase38.log

#tc qdisc add dev eth0 root netem duplicate 10%
currenttime testcase38.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc del dev eth0 root netem duplicate 10%
EOF
sleep 5

#juge result of test case 38
currenttime testcase38.log
compare 2>&1 | tee -a ./logs/testcase38.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase38.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase38.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase38.log | tee -a ./logs/Result.log
currenttime testcase38.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 39
#tc qdisc add dev eth0 root netem corrupt 5%
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase39.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase39.log | tee -a ./logs/Result.log
echo
echo "************ tc qdisc add dev eth0 root netem corrupt 5% ******************" | tee -a ./logs/testcase39.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase39.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase39.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase39.log

#tc qdisc add dev eth0 root netem corrupt 5%
currenttime testcase39.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc add dev eth0 root netem corrupt 5%
EOF
sleep 5

#insert data into xdc1
currenttime testcase39.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase39.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase39.log

#tc qdisc add dev eth0 root netem corrupt 5%
currenttime testcase39.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc del dev eth0 root netem corrupt 5%
EOF
sleep 5

#juge result of test case 39
currenttime testcase39.log
compare 2>&1 | tee -a ./logs/testcase39.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase39.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase39.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase39.log | tee -a ./logs/Result.log
currenttime testcase39.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

#run test case 40
#tc qdisc add dev eth0 root netem delay 100ms 10ms
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase40.log
echo "************************** Test Case $testcase_number *********************************" | tee ./logs/testcase40.log | tee -a ./logs/Result.log
echo
echo "************ tc qdisc add dev eth0 root netem delay 100ms 10ms ******************" | tee -a ./logs/testcase40.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase40.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase40.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase40.log

#tc qdisc add dev eth0 root netem delay 100ms 10ms
currenttime testcase40.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc add dev eth0 root netem delay 100ms 10ms
EOF
sleep 5

#insert data into xdc1
currenttime testcase40.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase40.log
sqlci -i ./sql/insert.sql 2>&1 | tee -a ./logs/testcase40.log

#tc qdisc del dev eth0 root netem delay 100ms 10ms
currenttime testcase40.log
sleep 5
su - root << EOF
linux
sleep 3
tc qdisc del dev eth0 root netem delay 100ms 10ms
EOF
sleep 5

#juge result of test case 40
currenttime testcase40.log
compare 2>&1 | tee -a ./logs/testcase40.log
if [ $? -eq 1 ]; then
let success_number=success_number+1
echo "************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase40.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase40.log | tee -a ./logs/Result.log
fi
echo "************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase40.log | tee -a ./logs/Result.log
currenttime testcase40.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 41
#Execute DML on different rows in single DC
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase41.log
echo "                ************************** Test Case $testcase_number *********************************" | tee ./logs/testcase41.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
echo
echo "                ************ Execute DML on different rows in single DC ******************" | tee -a ./logs/testcase41.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase41.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase41.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase41.log

#insert data into xdc1,at the same time, upsert data into xdc1 in different row
currenttime testcase41.log
echo "begin to insert and upsert data into xdc1 at the same time now !!!!" | tee -a ./logs/testcase41.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase41.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase41.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase41.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase41.log

#upsert using load into
currenttime testcase41.log
sh ./scripts/upsert_use_load.sh 2>&1 | tee -a ./logs/testcase41.log
sqlci -i ./sql/upsert_use_load.sql 2>&1 | tee -a ./logs/testcase41.log

#update data in different row at the same time
currenttime testcase41.log
echo "begin to  update data into xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase41.log
sh ./scripts/update.sh 2>&1 | tee -a ./logs/testcase41.log
sh ./scripts/update_101_200.sh 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/update.sql 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase41.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update.sql 2>&1 | tee -a ./logs/testcase41.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase41.log

#update data in different row at the same time
currenttime testcase41.log
echo "begin to delete data from xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase41.log
sh ./scripts/delete.sh 2>&1 | tee -a ./logs/testcase41.log
sh ./scripts/delete_101_200.sh 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/delete.sql 2>&1 | tee -a ./logs/testcase41.log
echo "exit" >> ./sql/delete_101_200.sql 2>&1 | tee -a ./logs/testcase41.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete.sql 2>&1 | tee -a ./logs/testcase41.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete_101_200.sql 2>&1 | tee -a ./logs/testcase41.log

#juge result of test case 41
currenttime testcase41.log
compare 2>&1 | tee -a ./logs/testcase41.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase41.log` -le '0' ]; then
let success_number=success_number+1
echo "                ************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase41.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "                ************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase41.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
fi
echo "                ************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase41.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
currenttime testcase41.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 42
#Execute DML on different rows in multi DC
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase42.log
echo "                ************************** Test Case $testcase_number *********************************" | tee ./logs/testcase42.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
echo
echo "                ************ Execute DML on different rows in multi DC ******************" | tee -a ./logs/testcase42.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase42.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase42.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase42.log

#insert data into xdc1,at the same time, upsert data into xdc1 in different row
currenttime testcase42.log
echo "begin to insert and upsert data into xdc1 at the same time now !!!!" | tee -a ./logs/testcase42.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase42.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase42.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase42.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase42.log

#upsert using load into
currenttime testcase42.log
sh ./scripts/upsert_use_load.sh 2>&1 | tee -a ./logs/testcase42.log
sqlci -i ./sql/upsert_use_load.sql 2>&1 | tee -a ./logs/testcase42.log

#update data in different row at the same time
currenttime testcase42.log
echo "begin to  update data into xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase42.log
sh ./scripts/update.sh 2>&1 | tee -a ./logs/testcase42.log
sh ./scripts/update_101_200.sh 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/update.sql 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase42.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update.sql 2>&1 | tee -a ./logs/testcase42.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase42.log

#update data in different row at the same time
currenttime testcase42.log
echo "begin to delete data from xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase42.log
sh ./scripts/delete.sh 2>&1 | tee -a ./logs/testcase42.log
sh ./scripts/delete_101_200.sh 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/delete.sql 2>&1 | tee -a ./logs/testcase42.log
echo "exit" >> ./sql/delete_101_200.sql 2>&1 | tee -a ./logs/testcase42.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete.sql 2>&1 | tee -a ./logs/testcase42.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/delete_101_200.sql 2>&1 | tee -a ./logs/testcase42.log

#juge result of test case 42
currenttime testcase42.log
compare 2>&1 | tee -a ./logs/testcase42.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase41.log` -le '0' ]; then
let success_number=success_number+1
echo "                ************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase42.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "                ************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase42.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
fi
echo "                ************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase42.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
currenttime testcase42.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 43
#Execute DML on different rows in single DC without primary key
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase43.log
echo "                ************************** Test Case $testcase_number *********************************" | tee ./logs/testcase43.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
echo
echo "                ************ Execute DML on different rows in single DC without primary key ******************" | tee -a ./logs/testcase43.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase43.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase43.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase43.log

#insert data into xdc1,at the same time, upsert data into xdc1 in different row
currenttime testcase43.log
echo "begin to insert and upsert data into xdc1 at the same time now !!!!" | tee -a ./logs/testcase43.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase43.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase43.log
sh ./scripts/delete.sh 2>&1 | tee -a ./logs/testcase43.log
sh ./scripts/delete_400_300.sh 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/delete.sql 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/delete_400_300.sql 2>&1 | tee -a ./logs/testcase43.log
sh ./scripts/update.sh 2>&1 | tee -a ./logs/testcase43.log
sh ./scripts/update_101_200.sh 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/update.sql 2>&1 | tee -a ./logs/testcase43.log
echo "exit" >> ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase43.log

#upsert using load into
currenttime testcase43.log
sh ./scripts/upsert_use_load.sh 2>&1 | tee -a ./logs/testcase43.log
sqlci -i ./sql/upsert_use_load.sql 2>&1 | tee -a ./logs/testcase43.log

#insert data into xdc1,at the same time, upsert data into xdc1 in different row
currenttime testcase43.log
echo "begin to insert and upsert data into xdc1 at the same time now !!!!" | tee -a ./logs/testcase43.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase43.log
trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase43.log
#update data in different row at the same time
echo "begin to  update data into xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase43.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update.sql 2>&1 | tee -a ./logs/testcase43.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete.sql 2>&1 | tee -a ./logs/testcase43.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase43.log &
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase43.log &
#update data in different row at the same time
echo "begin to delete data from xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase43.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete_400_300.sql 2>&1 | tee -a ./logs/testcase43.log &

#juge result of test case 43
currenttime testcase43.log
sleep 20
compare 2>&1 | tee -a ./logs/testcase43.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase43.log` -gt '0' ]; then
let success_number=success_number+1
echo "                ************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase43.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "                ************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase43.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
fi
echo "                ************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase43.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
currenttime testcase43.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log


#run test case 44
#Execute DML on different rows in multi DC without primary key
#testcase_number add
let testcase_number=testcase_number+1
currenttime Result.log
currenttime testcase44.log
echo "                ************************** Test Case $testcase_number *********************************" | tee ./logs/testcase44.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
echo
echo "                ************ Execute DML on different rows in multi DC without primary key ******************" | tee -a ./logs/testcase44.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log

#delete schema and create schema
currenttime Result.log
sqlci -i ./sql/delete_schema_create_schema.sql | tee -a ./logs/Result.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/delete_schema_create_schema.sql" | tee -a ./logs/Result.log

#create a syn table xdc1 on both DC
currenttime testcase44.log
sqlci -i ./sql/CreateSynTable_xdc1.sql 2>&1 | tee -a ./logs/testcase44.log
pdsh -w $dc2_ip_1 "sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable_xdc1.sql" | tee -a ./logs/testcase44.log

#insert data into xdc1,at the same time, upsert data into xdc1 in different row
currenttime testcase44.log
echo "begin to insert and upsert data into xdc1 at the same time now !!!!" | tee -a ./logs/testcase44.log
sh ./scripts/insert.sh 2>&1 | tee -a ./logs/testcase44.log
sh ./scripts/upsert.sh 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/insert.sql 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase44.log
echo "begin to delete data from xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase44.log
sh ./scripts/delete.sh 2>&1 | tee -a ./logs/testcase44.log
sh ./scripts/delete_400_300.sh 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/delete.sql 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/delete_400_300.sql 2>&1 | tee -a ./logs/testcase44.log
echo "begin to  update data into xdc1 in different rows at the same time now !!!!" | tee -a ./logs/testcase44.log
sh ./scripts/update.sh 2>&1 | tee -a ./logs/testcase44.log
sh ./scripts/update_101_200.sh 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/update.sql 2>&1 | tee -a ./logs/testcase44.log
echo "exit" >> ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase44.log
#upsert using load into
currenttime testcase44.log
sh ./scripts/upsert_use_load.sh 2>&1 | tee -a ./logs/testcase44.log
sqlci -i ./sql/upsert_use_load.sql 2>&1 | tee -a ./logs/testcase44.log

#update data in different row at the same time
currenttime testcase44.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/update.sql 2>&1 | tee -a ./logs/testcase44.log
nohup trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/update_101_200.sql 2>&1 | tee -a ./logs/testcase44.log

#update data in different row at the same time
currenttime testcase44.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/insert.sql 2>&1 | tee -a ./logs/testcase44.log
nohup trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/upsert.sql 2>&1 | tee -a ./logs/testcase44.log
nohup trafci.sh -h 10.10.23.31 -u db__root -p traf123 -s ./sql/delete.sql 2>&1 | tee -a ./logs/testcase44.log
trafci.sh -h $dc2_ip_1 -u db__root -p traf123 -s ./sql/delete_400_300.sql 2>&1 | tee -a ./logs/testcase44.log

#juge result of test case 44
currenttime testcase44.log
sleep 20
compare 2>&1 | tee -a ./logs/testcase44.log
if [ $? -eq 1 ] && [ `grep -c "ERROR" ./logs/testcase41.log` -le '0' ]; then
let success_number=success_number+1
echo "                ************************* Test Case $testcase_number is successfully ********************" | tee -a ./logs/testcase44.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
else
let failed_number=failed_number+1
echo "                ************************* Test Case $testcase_number is failed ********************" | tee -a ./logs/testcase44.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
fi
echo "                ************************* Test Case $testcase_number is compelted *********************" | tee -a ./logs/testcase44.log | tee ./logs/testcase40.log | tee -a ./logs/Result.log
currenttime testcase44.log
currenttime Result.log
echo | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log




#record the end time of this script
endtime=`date +'%Y-%m-%d %H:%M:%S'`
echo ">>>>>>>>>>>>>>:end time of this script is: $endtime" | tee -a ./logs/Result.log
echo | tee -a ./logs/Result.log

start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);

#total run time
echo ">>>>>>>>>>>>>:Total runtime is: "$((end_seconds-start_seconds))"s" | tee -a ./logs/Result.log

#run fucntion print_end_info
print_end_info


currenttime Result.log
echo
echo
echo ">>>>>>>>>>>: The Result Of XDC test is in /logs/Result.log !!!! "
echo
echo "                ************************************************************************"
