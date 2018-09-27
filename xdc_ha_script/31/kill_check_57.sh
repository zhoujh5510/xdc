#!/bin/bash

#check the xdc status of 57
#scp trafodion@10.10.23.57:/opt/trafodion/xdc_HA_script/check_status.log ./
echo "if curent DC xdc status is down, execute xdc_peer_up in peer DC"
if [ `grep -c "Done: xdc_peer_down" ./check_status_57.log` -gt '0' ]; then
        echo ">>>>>>>execute xdc_peer_up -p 57 in peer DC"
        xdc_peer_up -p 57
else
        echo ">>>>>>>Do Not execute xdc_peer_up -p in peer DC"
fi


echo "kill the process of xdc_peer_check"
#kill the process of xdc_peer_check
if [ `grep -c "Done: xdc_peer_down" ./check_status_57.log` -gt '0' ]; then
	echo ">>>>>>The process xdc_peer_check is exited, nothing to do"
else
	kill -9 $(ps -ef | grep xdc_peer_check | grep -v grep | awk '{print $2}')
fi
echo "test kill process xdc_peer_check and check xdc status is complete"

