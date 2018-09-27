#!/bin/bash


#execute xdc_peer_check -x -d 5 on peer DC
#if you run this scripts on other DC,you  should change ip address
echo ">>>>>>>execute xdc_peer_check in peer DC now"
nohup pdsh -w 10.10.23.57 "xdc_peer_check -d 5 -x | tee /opt/trafodion/xdc_HA_script/check_status.log" &
