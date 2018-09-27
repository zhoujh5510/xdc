#!/bin/bash


scp trafodion@10.10.23.57:/opt/trafodion/xdc_HA_script/check_status.log ./
echo "if curent DC xdc status is down, execute xdc_peer_up in peer DC"
if [ `grep -c "Done: xdc_peer_down" ./check_status.log` -gt '0' ]; then
        echo ">>>>>>>execute xdc_peer_up -p 31 in peer DC"
        pdsh -w 10.10.23.57 "xdc_peer_up -p 31"
else
        echo ">>>>>>>Do Not execute xdc_peer_up -p in peer DC"
fi


echo "kill the process of xdc_peer_check"
#kill the process of xdc_peer_check
if [ `grep -c "Done: xdc_peer_down" ./check_status.log` -gt '0' ]; then
	echo ">>>>>>The process xdc_peer_check is exited, nothing to do"
else
	kill -9 $(ps -ef | grep xdc_peer_check | grep -v grep | awk '{print $2}')
fi
echo "test kill process xdc_peer_check and check xdc status is complete"

pdsh -w 10.10.23.57 "rm -f /opt/trafodion/xdc_HA_script/check_status.log"
