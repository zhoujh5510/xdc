#!/bin/bash

#stop region server of 57
echo ">>>>>>>>stop region server of passive DC 57"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop regionserver"
EOF
echo "stop region server of passive DC 57 successfully "

