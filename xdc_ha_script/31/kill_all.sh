#!/bin/bash

#kill process of test_workload
echo "kill the process named test_workload.sh"
ps -efww|grep test_workload.sh |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill process of xdc_workload.sh
echo "kill the process named xdc_workload.sh"
ps -efww|grep xdc_workload,sh |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill process of xdc_workload1.sh
echo "kill the process named xdc_workload1.sh"
ps -efww|grep xdc_workload1.sh |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill process of xdc_peer_check
echo "kill the process named xdc_peer_check"
ps -efww|grep xdc_peer_check |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill all process which file name begin with testcase_
echo "kill the processes which process name begin with testcase_"
ps -efww|grep testcase_ |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill the process named check.sh
echo ">>>>>>kill the process named check.sh"
ps -efww|grep check.sh |grep -v grep|cut -c 9-15|xargs kill -9
echo

#kill the process named check_57.sh
echo ">>>>>>kill the process named check_57.sh"
ps -efww|grep check_57.sh |grep -v grep|cut -c 9-15|xargs kill -9
echo
