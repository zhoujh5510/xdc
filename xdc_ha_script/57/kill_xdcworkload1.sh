#!/bin/bash


workload_pid=$(ps -ef | grep xdc_workload1.sh | grep -v grep | awk '{print $2}')
kill -9 $workload_pid
